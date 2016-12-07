module Flic
  module Commands
    class Base
      include Flic::Encoding

      def initialize(args)
        super(args.unshift(self.class.opcode).unshift(:size))
      end
      alias_method :unpacked, :raw

      def packed
        packable = if self.class.bdaddr_at
          index = self.class.mapped_index(self.class.bdaddr_at)
          val = Flic::BluetoothAddr.parse(raw[index])

          raw.clone.tap {|t| t[index] = val.coded}.flatten
        else
          raw.clone
        end
        code_enums(packable)
        packable.shift # drop the :size placeholder

        enc = packable.pack("C#{self.class.packing}")
        "#{[enc.length].pack('S<')}#{enc}"
      end
    end

    class GetInfo < Base
      opcode 0
    end

    class CreateScanner < Base
      opcode 1
      packing 'L<'
      mapping %i|scan_id|
    end

    class RemoveScanner < Base
      opcode 2
      packing 'L<'
      mapping %i|scan_id|
    end

    class CreateConnectionChannel < Base
      opcode 3
      packing 'L<C7S<'
      mapping [:conn_id, [:addr, 6], :latency_mode, :auto_disconnect_time], true
      bdaddr_at :addr
      enums({9 => :LatencyMode})
    end

    class RemoveConnectionChannel < Base
      opcode 4
      packing 'L<'
      mapping %i|conn_id|
    end

    class ForceDisconnect < Base
      opcode 5
      packing 'C6'
      mapping [[:addr, 6]]
      bdaddr_at :addr
    end

    class ChangeModeParameters < Base
      opcode 6
      packing 'L<Cs'
      mapping %i|conn_id latency_mode auto_disconnect_time|
      enums({3 => :LatencyMode})
    end

    class Ping < Base
      opcode 7
      packing 'L<'
      mapping %i|ping_id|
    end

    class GetButtonUUID < Base
      opcode 8
      packing 'C6'
      mapping [[:addr, 6]]
      bdaddr_at :addr
    end

    class CreateScanWizard < Base
      opcode 9
      packing 'L<'
      mapping %i|scan_wizard_id|
    end

    class CancelScanWizard < Base
      opcode 10
      packing 'L<'
      mapping %i|scan_wizard_id|
    end
  end
end

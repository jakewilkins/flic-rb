module Flic
  module Events
    class Base
      include Flic::Encoding

      def initialize(str)
        super
        @size, @unpacked = unpack
      end

      def size
        unpacked[0]
      end

      def opcode
        unpacked[1]
      end

      def unpack
        u = raw.unpack("S<C#{self.class.packing}")
        decode_enums(u)
      end
    end

    class AdvertisementPacket < Base
      opcode 0
      packing 'L<C6CC16cC2'
      mapping [:scan_id, [:addr, 6], :name_length, [:name, 16], :rssi, :is_private, :already_verified]
      enums({27 => :Bool, 28 => :Bool})
    end

    class CreateConnectionChannelResponse < Base
      opcode 1
      packing 'L<CC'
      mapping %i|conn_id error status|
      enums({3 => :CreateConnectionChannelError, 4 => :ConnectionStatus})
    end

    class ConnectionStatusChanged < Base
      opcode 2
      packing 'L<CC'
      mapping %i|conn_id status disconnect_reason|
      enums({3 => :ConnectionStatus, 4 => :DisconnectReason})
    end

    class ConnectionChannelRemoved < Base
      opcode 3
      packing 'L<C'
      mapping %i|conn_id reason|
      enums({3 => :RemovedReason})
    end

    class ButtonEvent < Base
      packing 'L<CCL<'
      mapping %i|conn_id click_type queued time_diff|
      enums({3 => :ClickType})
    end
    class ButtonUpOrDown < ButtonEvent
      opcode 4
    end
    class ButtonClickOrHold < ButtonEvent
      opcode 5
    end
    class ButtonSingleOrDoubleClick < ButtonEvent
      opcode 6
    end
    class ButtonSingleOrDoubleClickOrHold < ButtonEvent
      opcode 7
    end

    class NewVerifiedButton < Base
      opcode 8
      packing 'C6'
      mapping [[:addr, 6]]
      bdaddr_at :addr
    end

    class GetInfoResponse < Base
      opcode 9
      packing 'CC6CCS<CCS<C*'
      mapping [:bluetooth_controller_state, [:my_bd_addr, 6], :my_bd_addr_type,
               :max_pending_connections, :max_concurrently_connected_buttons,
               :current_pending_connections, :currently_no_space_for_new_connection,
               :verified_buttons_count, [:button_addresses, :end]]
      bdaddr_at :my_bd_addr
      enums({8 => :BdAddrType, 14 => :Bool})
    end

    class NoSpaceForNewConnection < Base
      opcode 10
      packing 'C'
      mapping %i|max_concurrently_connected_buttons|
    end

    class GotSpaceForNewConnection < Base
      opcode 11
      packing 'C'
      mapping %i|max_concurrently_connected_buttons|
    end

    class BluetoothControllerStateChange < Base
      opcode 12
      packing 'C'
      mapping %i|state|
      enums(2 => :BluetoothControllerState)
    end

    class PingResponse < Base
      opcode 13
      packing 'L<'
      mapping %i|ping_id|
    end

    class GetButtonUUIDResponse < Base
      opcode 14
      packing 'C6C16'
      mapping [[:addr, 6], [:uuid, 16]]
      bdaddr_at :addr
    end

    class ScanWizardFoundPrivateButton < Base
      opcode 15
      packing 'L<'
      mapping %i|scan_wizard_id|
    end

    class ScanWizardFoundPublicButton < Base
      opcode 16
      packing 'L<C6CC16'
      mapping [:scan_wizard_id, [:addr, 6], :name_length, [:name, 16]]
    end

    class ScanWizardButtonConnected < Base
      opcode 17
      packing 'L<'
      mapping %i|scan_wizard_id|
    end

    class ScanWizardCompleted < Base
      opcode 18
      packing 'L<C'
      mapping %i|scan_wizard_id result|
      enums({3 => :ScanWizardResult})
    end

    ALL = Events.constants - [:Base, :ButtonEvent]
    OPCODES = ALL.each_with_object({}) do |name, hsh|
      klass = Events.const_get(name)
      hsh[klass.opcode] = klass
    end

    def self.parse(raw_str)
      OPCODES[raw_str.bytes[2]].new(raw_str)
    end
  end
end

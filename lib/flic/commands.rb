module Flic
  module Commands
    class Base
      include Flic::Encoding

      def self.opcode(arg = nil)
        arg ? (@opcode = arg) : @opcode
      end

      def initialize(args)
        super(args.unshift(self.class.opcode))
      end
    end

    class CreateConnectionChannel < Base
      opcode 3
      packing 'CL<C7S<'
      mapping %i|opcode conn_id addr latency_mode auto_disconnect_time|
      bdaddr_at :addr
    end
  end
end

module Flic
  module Events
    class Base
      include Flic::Encoding

      #def self.inherited(base)
        #base.send(:include, Flic::Encoding)
      #end

      def initialize(str)
        super
        @size, @unpacked = unpack
      end
    end

    class EvtCreateConnectionChannelResponse < Base
      packing 'CL<CC'
      mapping %i|opcode conn_id error status|
    end
  end
end

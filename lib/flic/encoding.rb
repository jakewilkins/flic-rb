module Flic
  module Encoding
    def self.included(base)
      base.send(:attr_reader, :raw, :unpacked, :size)
      p base
      base.extend(ClassMethods)
    end

    def self.inherited(base)
      puts 'ok'
      base.extend(ClassMethods)
    end

    module ClassMethods
      def packing(arg = nil)
        arg ?  (@packing = arg) : @packing
      end

      def mapping(arr = nil)
        if arr
          @mapping = arr
          arr.each_with_index do |name, ind|
            define_method(name) do
              unpacked[ind]
            end
          end
        else
          @mapping
        end
      end

      def mapped_index(name)
        @mapping.index(name)
      end

      def bdaddr_at(arg = nil)
        arg ? (@bdaddr_at = arg) : @bdaddr_at
      end
    end

    def initialize(arg)
      @raw = arg
    end

    def unpacked
      u = raw.unpack("S<#{self.class.packing}")
      [u.shift, u]
    end

    def packed
      packable = if self.class.bdaddr_at
                   index = self.class.mapped_index(self.class.bdaddr_at)
                   val = raw[index]
                   val = Flic::BluetoothAddr.new(val) unless val.is_a?(Flic::BluetoothAddr)
                   t = raw.clone
                   t[index] = val.coded
                   t.flatten
                 else
                   raw
                 end
      enc = packable.pack(self.class.packing)
      "#{[enc.length].pack('S<')}#{enc}"
    end

  end
end

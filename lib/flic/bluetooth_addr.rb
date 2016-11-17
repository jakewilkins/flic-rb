module Flic
  class  BluetoothAddr
    def self.parse(val)
      return val if val.is_a?(BluetoothAddr)
      new(val)
    end

    attr_reader :raw, :coding
    def initialize(arg)
      if arg.is_a?(Array)
        @raw = arg
        @raw = decoded
      else
        @raw = arg
      end
    end

    def coded
      split.reverse.map {|s| s.to_i(16)}
    end

    def decoded
      raw.unpack('C6').reverse.map {|i| i.to_s(16)}.join(':')
    end

    private

    def split
      raw.split(':')
    end
  end
end

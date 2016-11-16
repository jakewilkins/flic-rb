module Flic
  class  BluetoothAddr
    attr_reader :raw, :coding
    def initialize(str, coding = :str)
      if coding == :server
        @raw = str
        @raw = decoded
      else
        @raw = str
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

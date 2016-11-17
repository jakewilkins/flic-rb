module Flic
  class Client
    attr_reader :sock
    def initialize(options = {})
      @sock = TCPSocket.new(options[:host] || 'localhost', options[:port] || 5551)
    end

    def get_info
      command = Flic::Commands::GetInfo.new([])
      sock.send(command.packed, 0)
      get_one_event
    end

    def create_connection(id, addr, latency_mode, disconnect_time)
      command = Flic::Commands::CreateConnectionChannel.new([id, addr, latency_mode, disconnect_time])
      sock.send(command.packed, 0)
      get_one_event
    end

    def get_one_event
      raw_size = sock.recvmsg(2).first
      packet = sock.recvmsg(raw_size.unpack('S<').first).first
      Flic::Events.parse("#{raw_size}#{packet}")
    end

    def listen_for_events
      @listening = true
      while @listening
        event = get_one_event
        yield(event) if block_given?
        p event unless block_given? || ENV['DEBUG']
      end
    end
  end
end

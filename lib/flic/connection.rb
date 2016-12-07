module Flic
  class Connection
    attr_reader :sock, :queue, :var_mutex, :button_interests, :thread, :listening,
      :recv_sock_mutex, :send_sock_mutex
    private :var_mutex, :button_interests, :thread

    def initialize(options, queue)
      @queue = queue
      @sock = TCPSocket.new(options[:host] || 'localhost', options[:port] || 5551)
      @var_mutex = Mutex.new
      @recv_sock_mutex = Mutex.new
      @send_sock_mutex = Mutex.new
      @button_interests = {}
      @conn_id = Random.rand(24).to_i
      @thread = nil
    end

    def request_button_events(button_id, event_types)
      new_id = nil
      var_mutex.synchronize do
        new_id = @conn_id += 1
        button_interests[new_id] = {events: event_types, button_id: button_id}
      end
      create_connection(new_id, button_id, :normal, 200)
      start_listening_thread if thread.nil?
    end

    def request(command)
      send_sock_mutex.synchronize { sock.send(command.packed, 0) }
      return get_one_event unless listening
      :listening
    end

    def create_connection(id, addr, latency_mode, disconnect_time)
      command = Flic::Commands::CreateConnectionChannel.new([id, addr, latency_mode, disconnect_time])
      request(command)
    end

    def get_one_event
      raw_size, packet = nil, nil
      recv_sock_mutex.synchronize {
        raw_size = sock.recvmsg(2).first
        packet = sock.recvmsg(raw_size.unpack('S<').first).first
      }
      Flic::Events.parse("#{raw_size}#{packet}")
    end

    def listen_for_events(&block)
      var_mutex.synchronize { @listening = true }
      while var_mutex.synchronize { listening }
        event = get_one_event

        if !block.nil? && event_has_interest?(event)
          yielded = [button_interests[event.conn_id][:button_id],
                     [event.click_type, event.queued, event.time_diff]]
          yielded << event if block.arity == 3
          block.call(*yielded)
        end

        p event if ENV['DEBUG']
      end
    end

    private

    def start_listening_thread
      @thread = Thread.new do
        listen_for_events do |event, click_type|
          queue << [event, click_type]
        end
      end
    end

    def event_has_interest?(event)
      return false unless event.is_a?(Flic::Events::ButtonEvent)
      return false unless (evr = button_interests[event.conn_id])

      if event.is_a?(Flic::Events::ButtonSingleOrDoubleClickOrHold) || evr[:all]
        evr[:events].include?(event.click_type)
      else
        false
      end
    end

    def new_conn_id
      var_mutex.synchronize { @conn_id += 1 }
    end

  end
end

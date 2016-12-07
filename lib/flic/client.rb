module Flic
  class Client
    ButtonClick = Struct.new(:id, :click_type, :queued, :time_diff)
    attr_reader :connection, :queue
    def initialize(options = {})
      @queue = Queue.new
      @connection = Connection.new(options, queue)
    end

    def get_info
      connection.request(Flic::Commands::GetInfo.new([]))
    end

    def request_button_events(button_id, event_types)
      connection.request_button_events(button_id, event_types)
    end

    def button_events_pending?
      !queue.empty?
    end

    def pending_button_events
      arr = []
      until queue.empty?
        id, attrs = queue.pop
        arr << ButtonClick.new(*attrs.unshift(id))
      end
      arr
    end
  end
end


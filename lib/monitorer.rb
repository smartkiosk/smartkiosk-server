require 'em-websocket'

class MonitorConnection < EventMachine::WebSocket::Connection
  def initialize(service)
    @service = service
  end

  def trigger_on_open(handshake)
    @id = @service.channel.subscribe &method(:post_event)
  end

  def trigger_on_close(event = {})
    @service.channel.unsubscribe @id
  end

  private

  def post_event(event)
    send event
  end
end

class Monitorer
  cattr_reader :current
  attr_reader :channel

  def self.setup!(opts)
    @@current = Monitorer.new(opts)
  end

  def self.notify(event)
    current.notify(event) if current
  end

  def initialize(opts={})
    @channel = EventMachine::Channel.new
    EventMachine.start_server opts[:host], opts[:port], MonitorConnection, self
  end

  def notify(event)
    @channel.push JSON.dump(event)
  end
end

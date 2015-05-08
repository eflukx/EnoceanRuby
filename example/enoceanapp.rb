require 'logger'

class EnoceanApp

  class << self
    attr_accessor :logger
  end
  @logger = Logger.new(STDOUT)

  attr_accessor :reader, :writer, :listen_thread

  def initialize serial, loglevel = Logger::DEBUG
    EnoceanApp::logger.level = loglevel

    @serial  = serial
    @reader  = Enocean::Reader.new(serial)
    @writer  = Enocean::Writer.new(serial)
    @incoming_esp_packets = []
    @queued_packets = {}
  end

  def last_received_packet
    @incoming_esp_packets.last
  end

  def send_command cmd, *opts
    cmd_packet = Enocean::Esp3.const_get(cmd).create(*opts)
    send_packet cmd_packet
    cmd_packet
  end

  def send_packet packet
    @writer.write_packet packet
  end

  def start_listening
    @listen_thread = Thread.new {
      EnoceanApp::logger.debug "Start listening!"
      Thread.current[:run] = true

      while Thread.current[:run] do
        begin
          if esp_packet = @reader.read_packet(synchronous = false)
            @incoming_esp_packets << esp_packet
            yield esp_packet
          end
        rescue => e
          EnoceanApp::logger.error "Exception in listening thread #{Thread.current}: #{e}"
        end
        sleep 0.001
      end

    } unless listening?

    @listen_thread
  end

  def listening?
    if @listen_thread.class == Thread
      return @listen_thread.status
    end
    false
  end

  def stop_listening
    @listen_thread[:run] = false
    @listen_thread.terminate
  end

  def stop
    stop_listening
    @serial.close
  end
end
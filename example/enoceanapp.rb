require 'logger'

class EnoceanExample

  class << self
    attr_accessor :logger
  end
  @logger = Logger.new(STDOUT)

  attr_accessor :reader, :writer, :listen_thread, :next_setting, :serial, :incoming_esp_packets, :known_devices, :my_device_id, :logger

  def initialize serial, my_device_id = [0xde,0xad,0xbe, 0xef], known_devices_file = 'known_devices.yml'

    EnoceanExample::logger.level = Logger::DEBUG

    @serial  = serial
    @reader  = Enocean::Reader.new(serial)
    @writer  = Enocean::Writer.new(serial)

    @my_device_id         = Enocean::DeviceId.new my_device_id
    @incoming_esp_packets = []

    @known_devices_file   = known_devices_file
    init_known_devices
  end

  def init_known_devices
    @known_devices        = File.exists?(@known_devices_file) ? YAML.load_file(@known_devices_file) : {}
    EnoceanExample::logger.info "#{@known_devices.length} known devices loaded from #{@known_devices_file}"
  end

  def add_known_device packet, options = {}
    options = {save_to_file: true, active: false}.merge(options)
    puts "options: #{options}"

    device_key = packet.sender_id.to_s

    if @known_devices[device_key]
      EnoceanExample::logger.info "Device #{device_key} already known! Updating known devices list"
    else
      EnoceanExample::logger.info "Adding device #{device_key} to known devices list"
    end

    #TODO once active, will not deactivate anymore. Dp we need a special call for this?
    if @known_devices[device_key]
      set_active = @known_devices[device_key].fetch(:active, false) || options[:active]
    else
      set_active = options[:active]
    end

    @known_devices[device_key] = {active: set_active, packet: packet}

    EnoceanExample::logger.info "Device #{device_key} is #{set_active ? "active" : "not active"}"

    save_known_devices if options[:save_to_file]
  end

  def save_known_devices
    File.open(@known_devices_file, 'w+') { |file| file.write @known_devices.to_yaml }
  end

  # Creates a new request
  # Looks up eep class in known devices, and returns a new encapsulating ESP packet
  def eep_request_packet_by_devid setting, id
    if known_device =  @known_devices[id.to_s]
      dev_packet = known_device[:packet]

      eep_req = dev_packet.eep.eep_class::Request.new setting
      eep_req.summer = false

      req_packet                = eep_req.esp_packet
      req_packet.sender_id      = my_device_id
      req_packet.security_level = 0
      req_packet.subtel_num     = 1
      req_packet.dest_id        = dev_packet.sender_id
      req_packet
    end
  end

  def device_known? packet
    if @known_devices[packet.sender_id.to_s]
      true
    else
      false
    end
  end

  def device_active? packet
    if d = @known_devices[packet.sender_id.to_s]
      d.fetch(:active, false)
    else
      false
    end
  end

  def find_known_device packet
    @known_devices[packet.sender_id.to_s]
  end

  # Looks up the eep profile in the known devices list, decode telegram data with new eep object
  def decode_eep_data packet
    if packet.is_radio_packet? #needs to be a radio packet
      unless packet.learn?
        if known_device = find_known_device(packet) # We need to lookup the eep
          known_device[:packet].eep.eep_class::Response.new(packet.telegram_data) # got it
        end
      end
    end
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
      EnoceanExample::logger.debug "Start listening!"
      Thread.current[:run] = true

      while Thread.current[:run] do
        begin
          if esp_packet = @reader.read_packet(synchronous = false)
            @incoming_esp_packets << esp_packet
            yield esp_packet
          end
        rescue => e
          EnoceanExample::logger.error "Exception in listening thread #{Thread.current}: #{e}"
          raise
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
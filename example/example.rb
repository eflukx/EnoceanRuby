#!/usr/bin/env ruby
require 'serialport'
require '../lib/enocean'
require './enoceanapp'

unless ARGV[0]
  puts "Please invoke as '#{$PROGRAM_NAME} [TCM310 serial port/dev]'"
  exit -1
end

trap("SIGINT") do
  puts "\nBye now...sigint"
  app.stop
  exit 0
end

module Enocean
  ConfigFile = 'known_devices.yml'
  MyDeviceId = DeviceId.new [0xa,0xa,0x8, 0x5]
  app = EnoceanApp.new SerialPort.new(ARGV[0], 57600)

  $known_devices = File.exists?(ConfigFile) ? YAML.load_file(ConfigFile) : {}
  puts "-- #{$known_devices.length} known devices loaded from #{ConfigFile}"

  incoming_esp_packets = []
  next_setting = {}
  next_setting["01-85-b1-bc"] = 50
  outgoing_queue = {}

  handle_incoming_packet = ->(packet){
    puts "handling packet..."
  }

  add_device_to_known_devices = ->(packet){
    already_known =  $known_devices[packet.sender_id.to_s]
    puts "Device already known!" if already_known
    puts already_known ? "Updating device in known devices list" : "Adding device to known devices list"
    $known_devices[packet.sender_id.to_s] = packet

    File.open(ConfigFile, 'w+'){|file| file.write $known_devices.to_yaml}
  }

  # Creates a new request
  # Looks up eep class in known devices, and returns a new encapsulating ESP packet
  def self.eep_request_by_devid setting, id = "01-85-b1-bc"
    eep_obj = $known_devices[id.to_s].eep.eep_class::Request.new setting
    dest_id = $known_devices[id.to_s].sender_id
    eep_obj.summer=false
    req = eep_obj.esp_packet
    req.security_level=0
    req.subtel_num=1
    req.dest_id=dest_id
    req
  end

  # Looks up the eep profile in the known devices list, decode telegram data with new eep object
  def self.decode_eep_data packet
    if packet.is_radio_packet? #needs to be a radio packet
      unless packet.learn?
        if known_device = $known_devices[packet.sender_id.to_s] #we need to lookup the eep
          known_device.eep.eep_class::Response.new(packet.telegram_data) # got it
        end
      end
    end
  end
  
  # prints decoded ESP packet info on screen
  # @param [Enocean::Esp3::BasePacket] packet
  def self.show packet
    puts packet
    puts decode_eep_data(packet)
  end



  # Checks if a new setting is pending for device and returns packet
  response_package = ->(packet){
    if packet.is_radio_packet?
      periph_id = packet.sender_id.to_s
      if setting = next_setting[periph_id]
        puts "Found a new setting! Setting"
        out_pkg = eep_request_by_devid setting, periph_id
        out_pkg.sender_id = MyDeviceId #dat zijn wij :)
        out_pkg
      end
    end
  }

   app.start_listening do |packet|
    show packet

    incoming_esp_packets << packet

    if packet.learn?
      add_device_to_known_devices.(packet)
    else
      response = response_package.(packet)
      app.writer.write_packet response if response
    end
  end

  binding.pry

  app.listen_thread.join
end

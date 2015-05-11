#!/usr/bin/env ruby
require 'serialport'
require '../lib/enocean'
require './enoceanapp'

unless ARGV[0]
  puts "Please invoke as '#{$PROGRAM_NAME} [TCM310 serial port/dev]'"
  exit -1
end

module Enocean
  config_file = 'devices.yml'
  app = EnoceanApp.new SerialPort.new(ARGV[0], 57600)

  trap("SIGINT") do
    puts "\nBye now..."
    app.stop
    exit
  end

  trap("INT") do
    puts "\nBye now..."
    app.stop
    exit
  end


  $known_devices = File.exists?(config_file) ? YAML.load_file(config_file) : {}

  puts "#{$known_devices.length} known devices loaded from #{config_file}"

  # packet = $known_devices["01-85-b1-bc"]
  # Esp3::Radio.rorg_codes[pak.rorg].create pak.eep.eep_class::Request.new(32).data

  incoming_esp_packets = []
  outgoing_queue = {}

  handle_incoming_packet = ->(packet){
    puts "handling packet..."
  }

  add_device_to_known_devices = ->(packet){
    puts "Adding device to known devices list"
    puts "Device already known!" if $known_devices[packet.sender_id.to_s]
    $known_devices[packet.sender_id.to_s] = packet

    File.open(config_file, 'w+'){|file| file.write $known_devices.to_yaml}
  }

  app.start_listening do |packet|
    puts packet

    incoming_esp_packets << packet

    add_device_to_known_devices.(packet) if packet.learn?

    # do we have something to send?
    # Enocean::Eep::A5_20_01::Request.new(32).esp_packet.serialize
    key = packet.sender_id.to_s
    if outpacket = outgoing_queue[key]
      outpacket.serialize

    end



  end

  binding.pry

  app.listen_thread.join
end
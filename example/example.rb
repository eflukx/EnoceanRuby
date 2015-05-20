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

# === This is where the fun starts!
###############################################################################

app = EnoceanExample.new SerialPort.new(ARGV[0], 57600)
app.next_setting["01-85-b1-bc"] = 50

# prints decoded ESP packet info on screen
# @param [Enocean::Esp3::BasePacket] packet
show = ->(packet){

  puts packet
  puts app.decode_eep_data(packet)
}

handle_incoming_packet = ->(packet){
  puts "\n-- Handling incoming esp packet#{" (from #{packet.sender_id})" if packet.is_radio_packet?}...".yellow.bold

  show.(packet)

  if packet.is_radio_packet?
    peripheral_id = packet.sender_id.to_s

    # Checks if a new setting is pending for device and returns packet
    if new_setting = app.next_setting[peripheral_id]
      puts "\n-- Found a queued setting for device #{peripheral_id}! (new setting: #{new_setting})".cyan.bold

      puts "-- Sending response packet:".cyan.bold
      response = app.eep_request_packet_by_devid(new_setting, peripheral_id)
      show.(response)
      app.writer.write_packet response

    end
  end
}

app.start_listening do |packet|

  if packet.learn?
    app.add_device_to_known_devices packet
  else
    handle_incoming_packet.(packet)
  end

end

binding.pry
app.listen_thread.join

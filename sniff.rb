#!/usr/bin/env ruby

require "./lib/enocean"
require 'serialport'

packet = Enocean::Esp3::ReadIdBase.create

serial = SerialPort.new("/dev/ttyAMA0", 57600)
writer = Enocean::Writer.new(serial)
reader = Enocean::Reader.new(serial)
puts "Starting reading..."
loop do
  begin
    packet = reader.read_packet
    puts "#{Enocean::Esp3::Rps.factory(packet)}" if packet
  rescue => e
    puts "Error #{e.message}"
  end
end

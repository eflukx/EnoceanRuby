#!/usr/bin/env ruby

require 'serialport'
require './lib/enocean'
serial = SerialPort.new "COM9", 57600
p serial

class EnoceanApp

  attr_accessor :reader, :writer, :listen_thread

  def initialize serial
    @reader = Enocean::Reader.new(serial)
    @writer = Enocean::Writer.new(serial)
    @incoming_esp_packets = []
  end

  def last_received_packet
    @incoming_esp_packets.last
  end

  def send_command cmd, *opts
    cmdclass = Enocean::Esp3.const_get cmd
    cmd_packet = cmdclass.create(*opts)
    @writer.write_packet cmd_packet
    cmd_packet
  end

  def start_listening
    @listen_thread = Thread.new {
      while true do
        begin
          p "start!"
          pakket = @reader.read_packet(synchronous = true)
          p pakket
          @incoming_esp_packets << pakket
        rescue => e
          puts "waah #{e}"
        end
        sleep 0.01
      end
    }

    @listen_thread
  end

  def blocklisten
        while true do
        begin
          p "start!"
          pakket = @reader.read_packet(synchronous = true)
          p pakket
          @incoming_esp_packets << pakket
        rescue => e
          puts "waah #{e}"
        end
        sleep 0.01
      end
  end

  def stop_listening
    @listen_thread.terminate
  end

end

app = EnoceanApp.new serial
app.start_listening
binding.pry

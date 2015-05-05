#!/usr/bin/env ruby

require 'serialport'
require './lib/enocean'
sp = SerialPort.new "COM9", 57600

reader = Enocean::Reader.new(sp)
writer = Enocean::Writer.new(sp)

lastpacket = []
trd = Thread.new {
  while true do
    begin
      p "start!"
      pakket = reader.read_packet(synchronous = true)
      p pakket
      lastpacket = pakket
    rescue => e
      puts "waah #{e}"
    end
  sleep 0.01
  end
}

tst = Enocean::Esp3::Radio.new 1,[0xa5,1,2,3,4,5,6,7,8,9]
fac = Enocean::Esp3::BasePacket.factory 1, [0xa5,1,2,3,0xf0,5,6,7,8,9],[]
ab = Enocean::Esp3::Rorg4BS.create [1,2,3,0xf0,5,6,7,8,9]

tst = Enocean::Esp3::RorgRPS.create 23
Enocean::Esp3::RorgRPS.create.serialize == [85, 0, 7, 0, 1, 17, 246, 0, 255, 255, 255, 255, 0, 101]

Enocean::Esp3::BasePacket.factory(1, Enocean::Esp3::RorgRPS.create.data).serialize == Enocean::Esp3::RorgRPS.create.serialize

rnd=rand(255)
Enocean::Esp3::RorgRPS.create(rnd).telegram_data == rnd

binding.pry
trd.join
#
# def send_command command, data = [], opt_data = []
#   command_packet = Enocean::Esp3::CommonCommand.with_command command, data , opt_data
#   writer.write_packet command_packet
# end
#
# radio_pkt  = Enocean::Esp3::Radio.from_data [0xa5,0x80,0x80,0x34,0xf0, 0xbb,0xee,0xee,0xff,0]
# working_teach_in_response = Enocean::Esp3::Radio.from_data [0xa5,0x80,0x80,0x34,0xf0, 0xbb,0xee,0xee,0xff,0]
#
# def start_learnmode
#  send_command :CO_WR_LEARNMODE, [1,0,0,0,0]
# end
#
# def stop_learnmode
#   send_command :CO_WR_LEARNMODE, [0,0,0,0,0]
# end
# # teach_response = [0x55,0x0,0xa,0x7,0x1,0xeb,0xa5,0x80,0x8,0x34,0x80,0x1,0x85,0xb1,0xbc,0x0,0x1,0xff,0xff,0xff,0xff,0x36,0x0,0xde]

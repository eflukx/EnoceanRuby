#!/usr/bin/env ruby

require 'serialport'

open("/dev/tty", "r+") { |tty|
  tty.sync = true
  sp = SerialPort.new "/dev/ttyAMA0", 57600

  trd = Thread.new {
    while true do
      if (c = sp.getc)
        begin 
          puts "" if c.ord == 0x55
          puts c.ord.to_s(16)
        rescue
       end
      end
    end
  }
  
    
  while (line = tty.gets) do
    sp.write "Tosti!"
    p "got:#{line}, writen #{sp.write line} bytes. #{trd}"
    
  end
}

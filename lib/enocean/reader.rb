module Enocean
  class Reader
    def initialize(serial)
      @serial = serial
    end
    
    def read_packet
      byte = @serial.getbyte
      
      packet = nil
      
      if byte == 0x55

        header = Array.new(4) { |b| b = @serial.getbyte }
        header_crc = @serial.getbyte
        if header_crc == crc8(header)
          data_length = (header[0] << 8) | header[1]
          data = Array.new(data_length) { |b| b = @serial.getbyte }
          
          optional_data_length = header[2]
          optional_data = Array.new(optional_data_length) { |b| b = @serial.getbyte }

          packet_type = header[3]

          data_crc = @serial.getbyte

          if data_crc == crc8(data + optional_data)
            packet = Esp3::BasePacket.factory(packet_type, data, optional_data)
          end
        end
      end
      packet
    end
  end
end
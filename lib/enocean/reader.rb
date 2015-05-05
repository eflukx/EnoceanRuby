module Enocean
  class InvalidHeader < RuntimeError
  end
  class InvalidData < RuntimeError
  end
  
  class Reader
    def initialize(serial)
      @serial = serial

      def @serial.sync_getbyte
        while !(byte = self.getbyte) do
          sleep 0.001 # Yes a hack, reduces cpu load.
        end
        byte
      end

    end

    def read_packet(synchronous = false, packet_factory = Esp3::BasePacket)
      packet = nil

      if (synchronous ? @serial.sync_getbyte : @serial.getbyte) == 0x55

        header = Array.new(4) { |b| b = @serial.sync_getbyte }

        if !(@serial.sync_getbyte == crc8(header))
          raise InvalidHeader.new "Invalid CRC8 for Header"
        else

          data_length = (header[0] << 8) | header[1]
          data = Array.new(data_length) { |b| b = @serial.sync_getbyte }
          optional_data_length = header[2]
          optional_data = Array.new(optional_data_length) { |b| b = @serial.sync_getbyte }
          packet_type = header[3]

          if !(@serial.sync_getbyte == crc8(data + optional_data))
            raise InvalidData.new "Invalid CRC8 for Data"
          else
            packet = packet_factory.factory(packet_type, data, optional_data)
          end

        end

      end
      packet
    end
  end
end
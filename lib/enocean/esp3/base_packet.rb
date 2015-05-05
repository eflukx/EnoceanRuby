module Enocean
  module Esp3
    class BasePacket
      attr_reader :data, :optional_data, :packet_type
      def initialize(packet_type, data, optional_data = [])
        @packet_type = packet_type
        @data = data
        @optional_data = optional_data
        init_from_data
      end

      def init_from_data
      end
      
      def self.from_data(data = [], optional_data = [])
        type_id = data.shift
        return self.new(type_id, data, optional_data)
      end

      def header
        [@data.length, @optional_data.length, @packet_type].pack("nCC").unpack("C*")
      end

      # see Enocean Serial Protocol, section 1.6.1 Packet description
      def serialize
        [ 0x55 ] + self.header + [ crc8(header) ] + @data + @optional_data + [ crc8(@data + @optional_data) ]
      end

      def self.factory(packet_type, data, optional_data = [])

        if packet_type == Radio.type_id
          return Radio.from_data(data, optional_data)
        elsif packet_type == Response.type_id
          return Response.from_data(data,  optional_data)
        elsif packet_type == CommonCommand.type_id
          return CommonCommand.from_data(data,  optional_data)
        else
          return BasePacket.new(packet_type,  data,  optional_data)
        end
      end

    end
  end
end

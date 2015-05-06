module Enocean
  class Writer

    def initialize(serial)
      @serial = serial
    end
    
    def write_packet(packet)
      Enocean::Esp3::Response.next_expected_response_class = packet.response_class if packet.packet_type == Esp3::CommonCommand.type_id
      @serial.puts packet.serialize.pack("C*")
    end
  end
end
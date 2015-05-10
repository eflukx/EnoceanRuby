module Enocean
  module Esp3

    class BasePacket
      def base_info
        s  = "\n**** ESP Base info ****\n"
        s += "Time of display : #{Time.now}\n"
        s += "ESP3 packet type: 0x%02x (%s)\n" % [packet_type, self.class]
        s += "Data length     : %d\n" % data.length
        s += "Opt. data length: %d\n" % optional_data.length
        s
      end

      def content
        ""
      end

      def to_s
        return base_info + content + "\n"
      end
    end

    class Radio
      def content
        s = %Q\
**** Data ****
Rorg / Choice   : 0x#{rorg.to_s 16} (#{self.class.rorg_codes[rorg]})
Data            : 0x#{radio_data.hex_join("-")}
Sender ID       : 0x#{sender_id}
Status          : 0x#{status.to_s 16}
Learnmode       : #{learn?}\

        s << %Q\
EEP             : 0x#{eep.to_s}
Manufacturer    : #{eep.manufacturer_name} (0x#{eep.manuf.to_s 16})\ if eep

        if @optional_data.count > 0
            s <<  %Q\

**** Optional Data ****
SubTelNum       : #{subtel_num}
Destination ID  : 0x#{dest_id}
dBm             : -#{dbm}dBm
Security Level  : #{security_level}\
        else
            s <<  "\n\n(No optional data)\n"
        end
        s
      end
    end

    class CommonCommand
      def content
        "Decoded packet:\ncommand:       #{self.class.common_command_codes.key self.data[0]} (#{self.data[0]})\ndata:          #{self.data[1..-1]}\noptional_data: #{self.optional_data}\n"
      end
    end

  end
end

module Enocean
  module Esp3

    class BasePacket
      def base_info
        s =  "ESP3 packet type: 0x%02x (%s)\n" % [@packet_type, self.class]
        s += "Data length     : %d\n" % @data.length
        s += "Opt. data length: %d\n" % @optional_data.length
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
        s =<<-EOT
**** Data ****
Time of display : #{Time.now}
Choice          : 0x#{@rorg.to_s(16)} (#{self.class.rorg_codes[@rorg]})
Data            : 0x#{@radio_data.collect{ |d| d.to_s(16) }.join("-")}
Sender ID       : 0x#{@sender_id.to_s(16)}
Status          : 0x#{@status.to_s(16)}
Learnmode       : #{@learn}
#{"eep_function    : 0x#{@eep_func.to_s 16}" if @eep_func}
#{"eep_type        : 0x#{@eep_type.to_s 16}" if @eep_type}
#{"eep_manufacturer: 0x#{@eep_manuf.to_s 16}" if @eep_manuf}
**** Optional Data ****
EOT
        if @optional_data.count > 0
            #s +=  'SubTelNum       : {0:d}\n'.format(self.subTelNum)
            #s +=  'Destination ID: 0x{0:08x}\n'.format(self.destId)
            #s +=  'dBm             : {0:d}\n'.format(self.dBm)
            #s +=  'Security Level  : {0:d}\n'.format(self.SecurityLevel)
        else
            #s +=  'None\n'
        end
        return s
      end
    end

    class CommonCommand
      def content
        "Decoded packet:\ncommand:       #{self.class.common_command_codes.key self.data[0]} (#{self.data[0]})\ndata:          #{self.data[1..-1]}\noptional_data: #{self.optional_data}\n"
      end
    end

  end
end

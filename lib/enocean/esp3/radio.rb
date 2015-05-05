module Enocean
  module Esp3
    class Radio < BasePacket

      attr_accessor :sender_id, :radio_data, :rorg, :flags

      def self.type_id
        0x01
      end

      def self.rorg_codes
        {0xf6 => RorgRPS, 0xd5 => Rorg1BS, 0xa5 => Rorg4BS}#, 0xd2 => RorgVLD} not implemented/needed (yet)
      end

      def init_from_data
        @rorg           = @data[0]
        @radio_data     = @data[1..-6]
        @sender_id      = @data[-5..-2].pack("C*").unpack("N").first
        @status         = @data[-1]
        @learn          = learn
        @subTelNum,
        @destId,
        @dBm,
        @securityLevel  = @optional_data.pack("C*").unpack("BNBB")
        @repeatCount    = @status & 0x0F
        @flags          = {:t21 => (@status >> 5) & 0x01, :nu => (@status >> 4) & 0x01 }

        init_eep_profile
      end

      def init_eep_profile
        @eep_func = @eep_type = @eep_manuf = nil
      end

      def learn
        (@radio_data.last & 8) == 0
      end

      def self.from_data(data = [], optional_data = [])
        if rorg_class = rorg_codes[data[0]]           # if inherited class found instantiate that
          rorg_class.new type_id, data, optional_data
        else
          return self.new type_id, data, optional_data
        end
      end

    end
  end
end

module Enocean
  module Esp3
    class Rorg4BS < Radio
      def self.rorg_code
        0xa5
      end

      def self.create(data=[0,0,0,0], sender_id=[0xff,0xff,0xff,0xff], status = 0)
        base_data = [rorg_code] + data + sender_id + [status]
        return self.new(Enocean::Esp3::Radio.type_id, base_data)
      end

      def telegram_data
        @radio_data[0..3]
      end

      def learn_eep_provided?
        learn? && (@radio_data.last & 0x80) == 0x80
      end

      def init_eep_profile
        if learn? && learn_eep_provided?
          data  = @radio_data.pack("C*").unpack("N").first
          func     = (data & 0xff000000) >> 26
          type     = (data & 0x03f80000) >> 19
          manuf    = (data & 0x0007ff00) >> 8

          EepId.new [Rorg4BS.rorg_code, func, type, manuf]
        end
      end

    end

    class Rorg1BS < Radio
      def self.rorg_code
        0xd5
      end

      def self.create(data=0, sender_id=[0xff,0xff,0xff,0xff], status = 0)
        base_data = [rorg_code] + [data] + sender_id + [status]
        return self.new(Enocean::Esp3::Radio.type_id, base_data)
      end

      def telegram_data
        @radio_data.first
      end

    end

    class RorgRPS < Rorg1BS
      def self.rorg_code
        0xf6
      end

      def learn?
        false
      end
    end

    class RorgVLD
      def self.rorg_code
        0xd2
      end
      # not implemented !
    end
    
  end
end

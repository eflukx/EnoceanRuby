module Enocean
  module Esp3

    class Radio < BasePacket

      def self.type_id
        0x01
      end

      def self.rorg_codes
        {0xf6 => RorgRPS, 0xd5 => Rorg1BS, 0xa5 => Rorg4BS}#, 0xd2 => RorgVLD} not implemented/needed (yet)
      end

      def rorg
        data[0]
      end

      def radio_data
        data[1..-6]
      end

      def radio_data= newdata
        data[1..-6] = newdata if newdata.length == 4
      end

      def sender_id
        DeviceId.new data[-5..-2]
      end

      def sender_id= newid
        data[-5..-2] = DeviceId.new newid
      end

      def dest_id
        DeviceId.new optional_data[1..4]
      end

      def dest_id= newid
        optional_data[1..4] = DeviceId.new newid
      end

      def status
        data[-1]
      end

      def status= newstatus
        data[-1] = newstatus & 0xff
      end

      def subtel_num
        optional_data[0]
      end

      def subtel_num= subtel
        optional_data[0] = subtel.abs.clamp(0,255)
      end

      def dbm
        optional_data[5]
      end

      def dbm= dbm
        optional_data[5] = dbm.abs.clamp(0,255)
      end

      def security_level
        optional_data[6]
      end

      def security_level= seclvl
        optional_data[6] = seclvl & 0xff
      end

      def repeat_count
        data[-1] & 0x0f
      end

      def repeat_count= newrepcount
        data[-1] = (data[-1] & 0xf0) | (newrepcount & 0xf)
      end

      def flags
        {:t21 => (status >> 5) & 0x01, :nu => (status >> 4) & 0x01 }
      end

      def learn?
        (radio_data[-1] & 8) == 0
      end

      def learn= lrn
        lrn ? (data[-6] = data[-6] & 247) : (data[-6] = data[-6] | 8)
      end

      def self.from_data(data = [], optional_data = [])
        if rorg_class = rorg_codes[data[0]]           # if inherited "rorg" class found instantiate that
          rorg_class.new type_id, data, optional_data
        else
          return self.new type_id, data, optional_data
        end
      end

    end
  end
end

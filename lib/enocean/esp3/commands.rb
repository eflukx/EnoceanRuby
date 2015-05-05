module Enocean
  module Esp3
    # class CommonCommand
    class WriteSleep < CommonCommand
      def self.create msecs
        data  = Enocean::Tools.to_bytearray(msecs, 3).unshift 0
        with_command :CO_WR_SLEEP, data
      end
    end

    class WriteReset < CommonCommand
      def self.create
        with_command :CO_WR_RESET
      end
    end

    class ReadVersion < CommonCommand
      def self.create
        with_command :CO_RD_VERSION
      end
    end

    class ReadSysLog < CommonCommand
      # response!
      def self.create
        with_command :CO_RD_SYS_LOG
      end
    end

    class WriteSysLog < CommonCommand
      def self.create
        with_command :CO_WR_SYS_LOG
      end
    end

    class WriteSelfTest < CommonCommand
      #response!
      def self.create
        with_command :CO_WR_BIST
      end
    end

    class WriteIdBase < CommonCommand
      def self.create id
        data = Enocean::Tools.to_bytearray(id,3).unshift 0xff
        with_command :CO_WR_IDBASE, data
      end
    end

    class ReadIdBase < CommonCommand
      def self.create
        with_command :CO_RD_IDBASE
      end
    end

    # class ReadIdBaseResponse < Response
    #   def base_id
    #     data[1,4]
    #   end
    #   def self.factory(packet_type, data, optional_data)
    #     self.from_data(data)
    #   end
    # end


    class WriteFilterAdd < CommonCommand
      # 6  1 COMMAND Code   CO_WR_FILTER_ADD = 11
      # 7  1 Filter type    Device source ID = 0,
      #                     R-ORG = 1,
      #                     dBm = 2,
      #                     destination ID = 3
      # 8  4 Filter value   Value of filter function ’compare’:
      #                     - device source or destination ID
      #                     - R-ORG
      #                     - dBm value RSSI of radio telegram (unsigned, but interpreted as negative dBm value)
      # 12 1 Filter kind    blocks radio interface = 0x00, apply radio interface = 0x80, blocks filtered repeating = 0x40, apply filtered repeating = 0xC0

      def self.create value, type = 0, kind = 0
        data  = Enocean::Tools.to_bytearray(type, 1)
        data += Enocean::Tools.to_bytearray(value, 4)
        data += Enocean::Tools.to_bytearray(kind, 1)
        p data
        with_command :CO_WR_FILTER_ADD, data
      end
    end

    # end
  end
end
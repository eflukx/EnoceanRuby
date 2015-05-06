module Enocean
  module Esp3
    class CommonCommand < BasePacket
      def self.type_id
        0x05
      end

      def response_class
        Enocean::Esp3::Response
      end

      def self.from_data(data = [], optional_data = [])
        return self.new type_id, data, optional_data
      end

      def self.common_command_codes
        {:CO_WR_SLEEP=>1, :CO_WR_RESET=>2, :CO_RD_VERSION=>3, :CO_RD_SYS_LOG=>4, :CO_WR_SYS_LOG=>5,
         :CO_WR_BIST=>6, :CO_WR_IDBASE=>7, :CO_RD_IDBASE=>8, :CO_WR_REPEATER=>9, :CO_RD_REPEATER=>10,
         :CO_WR_FILTER_ADD=>11, :CO_WR_FILTER_DEL=>12, :CO_WR_FILTER_DEL_ALL=>13, :CO_WR_FILTER_ENABLE=>14,
         :CO_RD_FILTER=>15, :CO_WR_WAIT_MATURITY=>16, :CO_WR_SUBTEL=>17, :CO_WR_MEM=>18, :CO_RD_MEM=>19,
         :CO_RD_MEM_ADDRESS=>20, :CO_RD_SECURITY=>21, :CO_WR_SECURITY=>22, :CO_WR_LEARNMODE=>23, :CO_RD_LEARNMODE=>24,
         :CO_WR_SECUREDEVICE_ADD=>25, :CO_WR_SECUREDEVICE_DEL=>26, :CO_RD_SECUREDEVICE_BY_INDEX=>27, :CO_WR_MODE=>28,
         :CO_RD_NUMSECUREDEVICES=>29, :CO_RD_SECUREDEVICE_BY_ID=>30, :CO_WR_SECUREDEVICE_ADD_PSK=>31,
         :CO_WR_SECUREDEVICE_SENDTEACHIN=>32, :CO_WR_TEMPORARY_RLC_WINDOW=>33, :CO_RD_SECUREDEVICE_PSK=>34, :CO_RD_DUTYCYCLE_LIMIT=>35}
      end

      def self.get_command_code cmd
        if cmd.is_a? Numeric and common_command_codes.values.include? cmd
          cmd
        elsif cmd.is_a? String
          get_command_code cmd.upcase.to_sym
        else
          common_command_codes[cmd]
        end
      end

      def self.with_command(cmd, data = [], optional_data = [])
        if (cmd = get_command_code cmd)
          data.unshift cmd
          return self.new(type_id, data, optional_data)
        end
      end
    end

  end
end

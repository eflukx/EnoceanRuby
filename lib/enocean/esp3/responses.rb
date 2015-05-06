module Enocean
  module Esp3
    class ReadVersionResponse < Response
      def app_version
        data[1..4]
      end

      def api_version
        data[5..8]
      end

      def chip_id
        data[9..12]
      end

      def chip_version
        data[13..16]
      end

      def app_description
        data[17..32].select{|i| i != 0}.pack"C*"
      end

      def content
        "app version:     #{app_version}\n"+
        "api version:     #{api_version}\n"+
        "chip id:         #{chip_id}\n"+
        "chip version:    #{chip_version}\n"+
        "app description: #{app_description}\n"
      end
    end

    class ReadSysLogResponse < Response
      def api_log index = nil
        return data[1..-1][index] if index
        data[1..-1]
      end

      def app_log index = nil
        return optional_data[index] if index
        optional_data
      end
    end

    class ReadIdBaseResponse < Response
      def base_id
        data[1,4]
      end

      def content
        "base id: #{base_id}"
      end
    end

    class WriteBISTResponse < Response
      def result
        data[1]
      end

      def result_ok?
        result == 0
      end
      def content
        "result ok?: #{result_ok?}"
      end
    end

 end
end
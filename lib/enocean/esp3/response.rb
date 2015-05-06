
module Enocean
  module Esp3
    class Response < BasePacket

      # Next expected response is based on the last command send to the Enocean module.
      # This is set by the writer. Yep. agreed: it's a bit hacky...
      class << self
        attr_accessor :next_expected_response_class
      end

      def self.type_id
        return 0x02
      end
  
      def return_code
        data.first
      end
  
      def ok?
        return_code == 0
      end


      def return_message
        if return_code == 2
          return "ret_not_supported"
        elsif return_code == 3
          return "ret_wrong_param"
        end
        "ret_ok"
      end

      def content
        "return code: #{return_code} (#{return_message})"
      end

      def self.from_data(data = [], optional_data = [])
        if next_expected_response_class == self
          return self.new(type_id, data, optional_data)
        elsif next_expected_response_class
          return next_expected_response_class.from_data(data, optional_data)
        else
          return self.new(type_id, data, optional_data)
        end
      end

    end
  end
end

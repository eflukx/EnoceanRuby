module Enocean
  module Esp3
    class Event < BasePacket

      def self.type_id
        0x04
      end
  
      def event_code
        data.first
      end

      def self.event_codes
        {1=>ReclaimNotSuccessfulEvent, 2=>ConfimLearnEvent, 3=>LearnAckEvent, 4=>ReadyEvent, 5=>SecureDevicesEvent, 6=>DutyCycleLimitEvent}
      end

      def self.from_data(data = [], optional_data = [])
        if event_class = event_codes[data.first]
          return event_class.new(type_id, data, optional_data)
        end
        return self.new(type_id, data, optional_data)
      end

    end
  end
end

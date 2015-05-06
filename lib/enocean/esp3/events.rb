
module Enocean
  module Esp3
    class ReclaimNotSuccessfulEvent < Event
      def self.event_code
        0x01
      end
    end

    class ConfimLearnEvent < Event
      def self.event_code
        0x02
      end
    end

    class LearnAckEvent < Event
      def self.event_code
        0x03
      end
    end

    class ReadyEvent < Event
      def self.event_code
        0x04
      end

      def reset_cause
        data[1]
      end

      def content
        "Reset cause #{reset_cause}: "+
        case reset_cause
        when 0
          "Voltage supply drop or indicates that VDD > VON"
        when 1
          "Reset caused by usage of the reset pin (is set also after downloading the program with the programmer)"
        when 2
          "Watchdog timer counter reached the timer period"
        when 3
          "Flywheel timer counter reached the timer period"
        when 4
          "Parity error 05 = HW Parity error in the Internal or External Memory"
        when 6
          "A memory request from the CPU core does not correspond to any valid memory location. This error may be caused by a S/W malfunction."
        when 7
          "Wake-up pin 0 activated"
        when 8
          "Wake-up pin 1 activated"
        when 9
          "Unknown reset source - reset reason couldn't be detected"
        else
          "Unknown reset source - reset reason couldn't be detected"
        end
      end
    end

    class SecureDevicesEvent < Event
      def self.event_code
        0x05
      end
    end

    class DutyCycleLimitEvent < Event
      def self.event_code
        0x06
      end
    end
  end
end

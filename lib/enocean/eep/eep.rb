module Enocean
  class Eep

    def esp_packet *args
        Enocean::Esp3::Radio.rorg_codes[self.class.eep.rorg].create self.data, *args
    end

    class A5_20_01 < Eep

      def self.description
        "Battery Powered Actuator"
      end

      def self.to_s
        description
      end

      def self.eep
        EepId.new [0xa5,20,1]
      end

      def to_s
        data.hex_join '-'
      end

      def learn?
        (@data[0] & 0x8) == 0 ? true : false
      end

      class Response < A5_20_01

        attr_accessor :data

        def initialize data
          @data = Enocean::Tools.to_bytearray data, 4
        end

        def current_value
          @data[0]
        end

        def temperature
          (@data[2]*40)/255.0
        end

        def service_on
          (@data[1] & 0x80) >> 7
        end

        def energy_input_enabled
          (@data[1] & 0x40) >> 6
        end

        def energy_storage
          (@data[1] & 0x20) >> 5
        end

        def battery_capacity
          (@data[1] & 0x10) >> 4
        end

        def contact_open
          (@data[1] & 0x8) >> 3
        end

        def out_of_range
          (@data[1] & 0x4) >> 2
        end

        def window_open
          (@data[1] & 0x2) >> 1
        end

        def actuator_obstructed
          @data[1] & 0x1
        end

        def to_s
        %Q\
*** Data of #{self.class} ***
current_value         : #{current_value}
temperature           : #{"%.2f" % temperature}
service_on            : #{service_on}
energy_input_enabled  : #{energy_input_enabled}
energy_storage        : #{energy_storage}
battery_capacity      : #{battery_capacity}
contact_open          : #{contact_open}
out_of_range          : #{out_of_range}
window_open           : #{window_open}
actuator_obstructed   : #{actuator_obstructed}
\
        end

      end

      class Request < A5_20_01

        attr_accessor :setpoint, :rcu_temp, :init_seq, :valve_maint, :valve_closed,
                      :summer, :setpoint_sel, :setpoint_inv, :select_func

        def initialize  setpoint, rcu_temp = 0, init_seq = false, valve_maint = false, valve_closed = false,
                        summer = false, setpoint_sel = :position, setpoint_inv = false, select_func = :service_on

            @setpoint     = setpoint
            @rcu_temp     = rcu_temp
            @init_seq     = init_seq
            @valve_maint  = valve_maint
            @valve_closed = valve_closed
            @summer       = summer
            @setpoint_sel = setpoint_sel
            @setpoint_inv = setpoint_inv
            @select_func  = select_func
        end

        def setpoint_sel_data
          if @setpoint_sel == :position || @setpoint_sel == false
            return false
          elsif @setpoint_sel == :temperature ||  @setpoint_sel == true
            return true
          else
            false
          end
        end

        def select_func_data
          if @select_func == :service_on || @select_func == true
            return true
          elsif @select_func == :rcu || @select_func == false
            return false
          else
            true
          end
        end

        def setpoint_data
          sp = setpoint_sel_data ? (@setpoint * 255.0 / 40): (@setpoint > 100 ? 100 : @setpoint)
          (sp < 0 ? 0 : sp).truncate
        end

        def rcu_temp_data
          sp = @rcu_temp * 255.0 / 40
          (sp < 0 ? 0 : sp).truncate
        end

        # This class has wrong data layout to be a learn packet (should contain EEP info, no operational data)
        def no_learn
          8
        end

        def data
          flagz = 0
          flagz |= @init_seq          ? 0x80 : 0
          flagz |= @valve_maint       ? 0x20 : 0
          flagz |= @valve_closed      ? 0x10 : 0
          flagz |= @summer            ? 0x08 : 0
          flagz |= setpoint_sel_data  ? 0x04 : 0
          flagz |= @setpoint_inv      ? 0x02 : 0
          flagz |= select_func_data   ? 0x01 : 0

          [setpoint_data,rcu_temp_data,flagz,no_learn]
        end

      end

    end
  end
end

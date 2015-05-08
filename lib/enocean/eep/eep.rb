module Enocean
  module Eep

    class A5_20_01

      def self.description
        "Battery Powered Actuator"
      end

      def self.eep
        EepId.new [0xa5,20,1]
      end

      def self.to_s
        description
      end

      def to_s
        data.hex_join '-'
      end

      class Response < A5_20_01
        def initialize data
          @data = Enocean::Tools.to_bytearray data, 4
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

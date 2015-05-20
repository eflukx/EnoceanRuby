class Integer
  def clamp lower, upper
    self < lower ? lower : (self > upper ? upper : self)
  end
end

class Array
  def to_hexs
    self.pack("C*").unpack("H*").first
  end

  def hex_join delimiter = ''
    self.collect{|i| "%02x" % i }.join(delimiter)
  end
  
  def deserialize_esp_packet
    if self.shift == 0x55
    
      header = self[0..3]
      if self[4] != crc8(header)
        raise Enocean::InvalidHeader.new "Invalid CRC8 for Header"
      else

        data_length = (header[0] << 8) | header[1]
        optional_data_length = header[2]
        data          = self[5..4 + data_length]
        optional_data = self[-1 - optional_data_length..-2]
        if self[-1] != crc8(data + optional_data)
          raise Enocean::InvalidData.new "Invalid CRC8 for Data"
        else
        
          packet_type = header[3]
          Enocean::Esp3::BasePacket.factory(packet_type, data, optional_data)
        end
      end
    end  
  end
  
end

class String
  def to_byte_array
    self.unpack"C*"
  end
  
  def deserialize_esp_packet
    self.unpack("C*").deserialize_esp_packet
  end

  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def yellow;         brown.bold               end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\033[0m" end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
  def no_colors
    self.gsub /\033\[\d+m/, ""
  end

end

module Enocean

  module Tools
    def self.to_bytearray input, size
      if input.is_a? Array
        return (0..size - 1).collect{|i| input[i] ? input[i].to_i : 0 }
      elsif input.is_a? String
        to_bytearray input.to_i(16), size
      elsif input.is_a? Numeric
        (size - 1).downto(0).collect {|s| input.to_i >> 8*s & 0xff}
      end
    end
  end

  class DeviceId < Array
    def packed
      self.pack("C*").unpack("N").first
    end

    def to_s
      self[0..3].hex_join('-')
    end

    def to_json *args
      self.to_s.to_json args
    end
  end

  class EepId < Array

    def initialize data
      super[0..3]
    end

    def packed
      self.pack("C*").unpack("N").first
    end

    def rorg
      self[0]
    end

    def func
      self[1]
    end

    def type
      self[2]
    end

    def manuf
      self[3]
    end

    def manufacturer_name
      Enocean::Eep.manufacturers[manuf] || ''
    end

    def to_s
      self[0..2].hex_join('-')
    end

    def to_json *args
      self.to_s.to_json args
    end

    def eep_class
      Eep.const_get self[0..2].hex_join('_').upcase
    end

  end
end


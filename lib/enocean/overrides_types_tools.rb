class Array
  def to_hexs
    self.pack("C*").unpack("H*").first
  end

  def hex_join delimiter = ''
    self.collect{|i| "%02x" % i }.join(delimiter)
  end
end

class String
  def to_byte_array
    self.each_char.map{|i|i.ord}
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

    def eep_class
      Eep.const_get self[0..2].hex_join('_').upcase
    end

  end
end


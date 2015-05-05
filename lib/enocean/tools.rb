module Enocean
  module Tools
    def self.to_bytearray input, size
      if input.is_a? Array
        return (0..size - 1).collect{|i| input[i] ? input[i].to_i : 0 }
      elsif input.is_a? String
        parse input.to_i(16), size
      elsif input.is_a? Numeric
        (size - 1).downto(0).collect {|s| input.to_i >> 8*s & 0xff}
      end
    end
  end
end
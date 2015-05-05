class Array
  def to_hexs
    self.pack("C*").unpack("H*").first
  end      
end

class String
  def to_byte_array
    self.each_char.map{|i|i.ord}
  end
end

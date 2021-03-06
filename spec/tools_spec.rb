require 'spec_helper'
module  Enocean
  describe Enocean::Tools do

    describe ".to_bytearray" do
      it "should do a conversion from a String" do
        expect(Tools.to_bytearray "10203040",4).to eq [16, 32, 48, 64]
        expect(Tools.to_bytearray 'fff',3).to eq      [0, 15, 255]
        expect(Tools.to_bytearray '1020',1).to eq     [32]
      end

      it "should do a conversion from am Array" do
        expect(Tools.to_bytearray [0x2b, 0x40, 0x67, 0xd5],8).to eq [43, 64, 103, 213, 0, 0, 0, 0]
        expect(Tools.to_bytearray [0x2b, 0x40, 0x67, 0xd5],4).to eq [43, 64, 103, 213]
        expect(Tools.to_bytearray [0x2b, 0x40, 0x67, 0xd5],2).to eq [43, 64]
        expect(Tools.to_bytearray [1,2,3,4,52.7],13).to eq [1, 2, 3, 4, 52, 0, 0, 0, 0, 0, 0, 0, 0]

      end

      it "should do a conversion from a Numeric" do
        expect(Tools.to_bytearray 0x10203040, 4).to eq [16, 32, 48, 64]
        expect(Tools.to_bytearray 0xfff,3).to eq      [0, 15, 255]
        expect(Tools.to_bytearray 241020,4).to eq     [0, 3, 173, 124]
      end
    end

  end

  describe "Enocean::EepId" do
    eep = EepId.new [0xa5,0x20,1,0x34]

    it "should find the right Eep class based on eep data" do
      expect(eep.eep_class).to be Enocean::Eep::A5_20_01
    end

    it "should return rorg, type, func and manuf" do
      expect(eep.rorg).to eq 0xa5
      expect(eep.func).to eq 0x20
      expect(eep.type).to eq 0x01
      expect(eep.manuf).to eq 0x34
    end

  end

end
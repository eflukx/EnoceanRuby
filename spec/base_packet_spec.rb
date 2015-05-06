require 'spec_helper'

describe Enocean::Esp3::BasePacket do
  let(:packet) { Enocean::Esp3::BasePacket.new(0x9, [ 0x8 ], [ 0x9 ]) }

  it "should serialze the packet correctly" do
    packet.serialize.should == [ 0x55, 0x00, 0x01, 0x01, 0x9, 0x41, 0x8, 0x9, 0x97 ]
  end
  
  it "should be able to print the packet" do
    packet.to_s.should_not be_nil
  end

  it "serialization and de-serialization should be equal" do
    factory_from_packet_data = Enocean::Esp3::BasePacket.factory(1, Enocean::Esp3::RorgRPS.create.data)
    packet_create = Enocean::Esp3::RorgRPS.create
    expect(factory_from_packet_data.serialize).to eq packet_create.serialize
  end

  it "Expect telgram data to be correctly emcapsulated" do
    rnd = rand(255)
    expect(Enocean::Esp3::RorgRPS.create(rnd).telegram_data).to eq rnd
  end

end


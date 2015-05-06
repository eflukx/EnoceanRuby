require 'spec_helper'

describe Enocean::Esp3::Response do
  it "should generate the correct response packet depending on the last command" do
    Enocean::Esp3::Response.next_expected_response_class = nil
      response = Enocean::Esp3::BasePacket.factory 2, [0,0,0,0]
      expect(response).to be_an_instance_of Enocean::Esp3::Response
      expect(response.ok?).to be true
      response = Enocean::Esp3::BasePacket.factory 2, [1,0,0,0]
      expect(response.ok?).to be false

    Enocean::Esp3::Response.next_expected_response_class = Enocean::Esp3::WriteBISTResponse
      response = Enocean::Esp3::BasePacket.factory 2, [0x0, 0x10]
      expect(response).to be_an_instance_of Enocean::Esp3::WriteBISTResponse
      expect(response.ok?).to be true

    Enocean::Esp3::Response.next_expected_response_class = Enocean::Esp3::ReadIdBaseResponse
      response = Enocean::Esp3::BasePacket.factory 2, [0x0, 0xff, 0x0, 0x1, 0x2]
      expect(response.ok?).to be true
      expect(response.base_id).to eq [0xff, 0x0, 0x1, 0x2]

    Enocean::Esp3::Response.next_expected_response_class = Enocean::Esp3::ReadSysLogResponse
      response = Enocean::Esp3::BasePacket.factory 2, [0x0, 1,2,3], [4,5,6]
      expect(response.ok?).to be true
      expect(response.api_log).to eq [1,2,3]
      expect(response.app_log).to eq [4,5,6]
      expect(response.api_log 1).to be 2
      expect(response.app_log 2).to be 6

    Enocean::Esp3::Response.next_expected_response_class = Enocean::Esp3::ReadVersionResponse
      response = Enocean::Esp3::BasePacket.factory 2, [0, 2, 7, 1, 0, 2, 4, 2, 1, 1, 133, 59, 195, 69, 79, 1, 3, 71, 65, 84, 69, 87, 65, 89, 67, 84, 82, 76, 0, 0, 0, 0, 0]
      expect(response.app_description).to eq "GATEWAYCTRL"
  end
end
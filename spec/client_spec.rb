require 'spec_helper'

def stub_requests
  stub_request(:any, /www.example.com/).
      to_return(lambda do |request|
        File.new("spec/response_data/#{request.method}/#{request.uri.path.split('/').last}.txt")
      end)
end

describe Blackbaud::Client do

  before :all do
    stub_requests

    options = {
        :database_key => "database_key",
        :database_number => 1,
        :vendor_id => 'vendor_id',
        :vendor_key => 'vendor_key',
        :url => "https://www.example.com"
    }
    @client = Blackbaud::Client.new(options)
  end

  before :each do
    stub_requests
  end


  describe "#initalize" do
    context "given auth params" do
      it "gets an auth token" do
        expect(@client.connector.token).to eq 'abcdefgh-1234-zyxw-9876-ijklmnopqrst_1'
      end
    end
  end

  describe "#get_class_marking_columns" do
    context "initialized and given an ea7_class_id" do
      it "gets marking_column data" do
        r = @client.get_class_marking_columns(7)
        expect(r.size).to eq 6
      end
    end
  end
end


require 'spec_helper'

RSpec.describe Blackbaud::Client, "#get_token" do
 context "given auth params" do
   it "get an auth token" do

     stub_request(:any, /https:\/\/www.example.com.*/).
       to_return(:status => 200, :body => '{"database_key": "database_key","database_number": 1,"token": "abcdefgh-1234-zyxw-9876-ijklmnopqrst_1","vendor_id": "vendor_id"}', :headers => {})

     options = {
       :database_key => "database_key",
       :database_number => 1,
       :vendor_id => 'vendor_id',
       :vendor_key => 'vendor_key',
       :url => "https://www.example.com"
     }

     client = Blackbaud::Client.new(options)

     expect(client.connector.token).to eq 'abcdefgh-1234-zyxw-9876-ijklmnopqrst_1'

   end
  end
end

require 'rspec'
require_relative 'client.rb'

describe Client do

  context "with an empty doc and empty hyperschema" do
    it "returns an empty list" do
      client = Client.new("{}", "{}")

      expect(client.get_links).to eq([])
    end
  end

  context "with a real example!" do
    it "returns list of links" do

    end
  end

end

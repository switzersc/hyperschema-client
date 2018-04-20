require 'rspec'
require 'webmock/rspec'
require_relative 'client.rb'

describe Client do

  describe "#get_links" do
    context "with an empty doc and empty hyperschema" do
      it "returns an empty list" do
        client = Client.new("{}", "{}")

        expect(client.get_links).to eq([])
      end
    end

    context "with a non-empty schema and doc" do
      let!(:schema) { File.read("example_hyperschema.json") }
      let!(:doc) { File.read("example_json_doc.json") }

      it "returns list of links" do
        client = Client.new(doc, schema)

        expect(client.get_links.size).to eq(2)
      end

      it "returns the LDO as is if there are no template variables" do
        client = Client.new(doc, schema)

        expect(client.get_links).to include({"rel" => "author","href" => "https://api.example.com/author"})
      end

      it "replaces variables in the URI template" do
        client = Client.new(doc, schema)

        expect(client.get_links).to include({"rel" => "self","href" => "https://api.example.com/things/1"})
      end
    end
  end

  describe ""
end

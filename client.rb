require 'json'
require 'uri_template'
require 'net/http'

class Client
  attr_reader :json_doc, :json_hyperschema

  def self.run
    # puts "What document would you like to parse?"
    # doc = "/Users/vandal/dev/hyperschema-client/example_json_doc.json"
    # puts "What schema would you like to use?"
    # schema = "/Users/vandal/dev/hyperschema-client/example_hyperschema.json"

    puts "What is home?"
    base_url = gets.chomp
    uri = URI(base_url)

    response =  Net::HTTP.get_response(uri)
    puts response

    puts "headers are:"
    puts response.to_hash.inspect

    # client = self.new(File.read(doc), File.read(schema))
    #
    # puts "Here are your links: "
    # retrieved_links = client.get_links
    # puts retrieved_links
    #
    # puts "Which do you want to follow?"
    #
    # rel = gets.chomp
    #
    # link = retrieved_links.select{|link| link["rel"] == rel}
    # puts link
    # url = link["href"]
    # puts Net::HTTP.get(url)
    # getting the doc at this URL
    # return the entire doc


  end

  def initialize(json_doc, json_hyperschema)
    @json_doc = JSON.parse json_doc
    @json_hyperschema = JSON.parse json_hyperschema
  end

  def get_links
    links.map do |link|
      template = URITemplate.new(link["href"])
      link["href"] = template.expand(json_doc)
      link
    end
  end

  # def follow(retrieved_links, rel)
  #
  # end

  def links
    json_hyperschema["links"] || []
  end
end


Client.run

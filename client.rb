require 'json'
require 'uri_template'
require 'net/http'
require "link_header"
require "rest-client"

class Client
  attr_reader :json_doc, :json_hyperschema

  def self.run
    # puts "What document would you like to parse?"
    # doc = "/Users/vandal/dev/hyperschema-client/example_json_doc.json"
    # puts "What schema would you like to use?"
    # schema = "/Users/vandal/dev/hyperschema-client/example_hyperschema.json"

    puts "What is home?"
    base_url = gets.chomp

    puts "Do you want to get the schema?"
    response = gets.chomp

    until response == "exit" do

      response = RestClient.get(base_url)
      puts response

      header_links = LinkHeader.parse(response.headers[:link]).to_a
      schema_url = base_url + header_links[0][0]
      schema = RestClient.get(schema_url)

      client = self.new(response, schema)

      puts "Here are your links: "
      retrieved_links = client.get_links
      puts retrieved_links

      puts "Which do you want to follow?"

      rel = gets.chomp


      link = retrieved_links.select{ |link| link["rel"] == rel }.first
      url = base_url + link["href"]
      last_response = RestClient.get(url)

      puts "Here's what we found:"
      puts last_response

      puts "Now what?"
      puts "(exit to stop)"
      response = gets.chomp
    end

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

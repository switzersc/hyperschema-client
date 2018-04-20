require 'json'
require 'uri_template'
require 'net/http'
require "link_header"
require "rest-client"

class Client
  attr_reader :json_doc, :json_hyperschema

  def self.run
    puts "What is home?"
    base_url = "https://hyper-api-example.herokuapp.com"

    response = RestClient.get(base_url)
    puts response

    user_will = "continue"

    loop do
      options = {
        "Go home" => nil,
        "Exit" => nil
      }
      header_links = LinkHeader.parse(response.headers[:link]).to_a

      if !header_links.empty?
        schema_url = base_url + header_links[0][0]
        schema = RestClient.get(schema_url)

        client = self.new(response, schema)

        retrieved_links = client.get_links
        retrieved_links.map do |link|
          key = link["title"] || link["rel"]
          options[key] = link["rel"]
        end
      end

      puts "What do you want to do?"
      puts options.keys

      option = gets.chomp

      break if option == "Exit"

      if option == "Go home"
        response = RestClient.get(base_url)
      end

      next if option == "Go home"

      rel = options[option]
      link = retrieved_links.select{ |link| link["rel"] == rel }.first
      url = base_url + link["href"]

      case rel
        when "create"
          submission_schema_url = base_url + link["submissionSchema"]["$ref"]
          submission_schema = RestClient.get(submission_schema_url)

          schema_hash = JSON.parse(submission_schema)
          required = schema_hash["required"]

          form_body = {}
          schema_hash["properties"].each do |property_name, property_info|
            if property_info["readOnly"] == true
              form_body[property_name] = schema_hash[property_name]
            else

              puts property_name + " | " + property_info["type"] + " | " + required.include?(property_name).to_s

              value = gets.chomp

              if property_info["type"] == "integer"
                form_body[property_name] = value.to_i
              else
                form_body[property_name] = value
              end
            end
          end

          begin
            response = RestClient.post(url, form_body.to_json, {content_type: :json, accept: :json})
          rescue RestClient::ExceptionWithResponse => e
            puts e.response
          end

        when "put"
          schema_hash = client.json_hyperschema
          required = schema_hash["required"]

          form_body = {}
          resp_hash = JSON.parse response
          schema_hash["properties"].each do |property_name, property_info|
            if property_info["readOnly"] == true
              form_body[property_name] = resp_hash[property_name]
            else
              puts property_name + " | " + property_info["type"] + " | " + required.include?(property_name).to_s + " | " + resp_hash[property_name].to_s

              value = gets.chomp

              if value.empty?
                value = resp_hash[property_name]
              end

              if property_info["type"] == "integer"
                form_body[property_name] = value.to_i
              else
                form_body[property_name] = value
              end
            end

          end

          begin
            response = RestClient.put(url, form_body.to_json, {content_type: :json, accept: :json})
          rescue RestClient::ExceptionWithResponse => e
            puts e.response
          end
        when "delete"
          response = RestClient.delete(url)

        else
          response = RestClient.get(url)
      end

      puts "Here's what we found:"
      puts response
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

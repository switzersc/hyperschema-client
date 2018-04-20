require 'json'
require 'uri_template'

class Client
  attr_reader :json_doc, :json_hyperschema

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

  def links
    json_hyperschema["links"] || []
  end
end

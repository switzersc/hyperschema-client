class Client
  attr_reader :json_doc, :json_hyperschema

  def initialize(json_doc, json_hyperschema)
    @json_doc = json_doc
    @json_hyperschema = json_hyperschema
  end

  def get_links
    hash = JSON.parse json_doc
    []
  end
end

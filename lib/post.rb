module Wordpress
  class Post
    attr_accessor :id, :title, :content, :excerpt, :publish_date

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        accessor_name = "#{attribute}="
        send(accessor_name, value) if respond_to?(accessor_name)
      end
    end #initialize

    def to_struct
      struct = {}
      struct[:title] = title if title
      struct[:description] = content if content
      struct[:mt_excerpt] = excerpt if excerpt
      struct[:dateCreated] = publish_date if publish_date
      struct
    end #to_struct
  end
end

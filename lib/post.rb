module Wordpress
  class Post
    attr_accessor :title, :content

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        accessor_name = "#{attribute}="
        send(accessor_name, value) if respond_to?(accessor_name)
      end
    end #initialize
  end
end

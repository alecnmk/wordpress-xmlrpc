module Wordpress
  class Post
    ATTRIBUTE_MATCHES = {
      :title => :title,
      :content => :description,
      :excerpt => :mt_excerpt,
      :creation_date => :dateCreated,
      :id => :postid
    }

    attr_accessor(
                  :id,
                  :title,
                  :content,
                  :excerpt,
                  :creation_date,
                  :published
                  )

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        accessor_name = "#{attribute}="
        send(accessor_name, value) if respond_to?(accessor_name)
      end
    end #initialize

    def self.from_struct(struct)
      post = Post.new
      ATTRIBUTE_MATCHES.each do |post_attribute, struct_attribute|
        post.send("#{post_attribute}=", struct[struct_attribute])
      end
      post.published = struct[:post_state] == "publish"
      post
    end #self.from_struct

    def to_struct
      struct = {}
      ATTRIBUTE_MATCHES.each do |post_attribute, struct_attribute|
        value = self.send(post_attribute)
        struct[struct_attribute] = value if value
      end
      struct
    end #to_struct

    def creation_date=(value)
      case value
      when String
        @creation_date = Date.parse(value)
      when Date
        @creation_date = value
      when nil
        @creation_date = value
      else
        raise ArgumentError, "Date or String expected instead of #{value.class.name}"
      end
    end #publish_date=
  end
end

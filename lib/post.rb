module Wordpress
  class Post
    include ContentItem

    ATTRIBUTE_MATCHES = {
      :metaWeblog => {
        :postid         => :id,
        :title          => :title,
        :description    => :content,
        :mt_excerpt     => :excerpt,
        :dateCreated    => :creation_date,
        :post_state     => :struct_published
      },
      :wp => {
      }
    }

    attr_accessor(:published)

    def struct_published=(value)
      @published = value if [true, false].include? value
      @published = value == "publish" if value.kind_of? String
    end

    def struct_published()
      return "publish" if @published == true
      return nil
    end #struct_published

  end
end

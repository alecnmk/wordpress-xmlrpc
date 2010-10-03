module Wordpress
  class Page
    include ContentItem

    ATTRIBUTE_MATCHES = {
      :title => :title,
      :content => :description,
      :excerpt => :mt_excerpt,
      :creation_date => :dateCreated,
      :struct_published => :post_state,
      :id => :postid
    }

  end
end

module Wordpress
  class Page
    include ContentItem

    ATTRIBUTE_MATCHES = {
      :metaWeblog => {
      },
      :wp => {
        :page_id => :id,
        :title => :title,
        :description => :content,
        :mt_excerpt => :excerpt,
        :dateCreated => :creation_date,
        :page_status => :status,
        :page_parent_id => :parent_id
      }
    }

    attr_accessor(:parent_id, :parent, :status)

  end
end

module Wordpress
  class Page
    include ContentItem

    ATTRIBUTE_MATCHES = {
      :metaWeblog => {
      },
      :wp => {
        :page_id => :id,
        :title => :title,
        :page_title => :title,
        :description => :content,
        :mt_excerpt => :excerpt,
        :dateCreated => :creation_date,
        :page_parent_id => :parent_id,
        :wp_page_parent_id => :parent_id
      }
    }

    attr_accessor(:parent_id, :published)
    attr_reader(:parent)

    def parent=(page)
      if page.nil?
        @parent_id = @parent = nil
      else
        raise "Page expected instead of #{page}" unless page.kind_of? Wordpress::Page
        @parent = page
        @parent_id = page.id
      end
    end #parent=

  end
end

module Wordpress
  module ContentItem
    module ClassMethods
      def from_struct(struct)
        content_item = self.new
        self::ATTRIBUTE_MATCHES.each do |item_attribute, struct_attribute|
          content_item.send("#{item_attribute}=", struct[struct_attribute])
        end
        content_item
      end #self.from_struct
    end

    module InstanceMethods
      def initialize(attributes = {})
        super()
        self.images = []
        apply_attributes(attributes)
      end #initialize

      def to_struct
        struct = {}
        self.class::ATTRIBUTE_MATCHES.each do |item_attribute, struct_attribute|
          value = self.send(item_attribute)
          struct[struct_attribute] = value if value
        end
        struct
      end #to_struct

      def struct_published=(value)
        @published = value if [true, false].include? value
        @published = value == "publish" if value.kind_of? String
      end

      def struct_published()
        return "publish" if @published == true
        return nil
      end #struct_published

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
      end #creation_date=

      protected

      def apply_attributes(attributes)
        attributes.each do |attribute, value|
          accessor_name = "#{attribute}="
          send(accessor_name, value) if respond_to?(accessor_name)
        end
      end
    end

    def self.included(host)
      host.send :include, InstanceMethods

      host.class_eval do
        attr_accessor(
                      :id,
                      :title,
                      :content,
                      :excerpt,
                      :images,
                      :published
                      )
        attr_reader(:creation_date)
      end

      host.extend ClassMethods
    end #included

  end
end

require 'xmlrpc/client'
require 'params_check'
require 'mimemagic'
require 'nokogiri'

module Wordpress
  class Blog
    include ParamsCheck
    include Loggable

    def initialize(params = {})
      @blog_uri = URI.parse(check_param(params, :blog_uri))

      @xmlrpc_path = params[:xmlrpc_path] || "xmlrpc.php"

      @id = params[:blog_id] || 0

      @user = check_param(params, :user)

      @password = check_param(params, :password)

      @client = XMLRPC::Client.new2(URI.join(@blog_uri.to_s, @xmlrpc_path).to_s)
    end #initialize

    def get_post(post_id)
      Post.new(api_call("metaWeblog.getPost", post_id, @user, @password))
    end #get_post

    def recent_posts(number_of_posts)
      blog_api_call("metaWeblog.getRecentPosts", number_of_posts).collect do |struct|
        Post.from_struct(:metaWeblog, struct)
      end
    end #recent_posts

    def publish(item)
      process_images(item) unless item.images.nil?
      case item
      when Wordpress::Post
        item.id = blog_api_call("metaWeblog.newPost", item.to_struct(:metaWeblog), true).to_i
        item.published = true
      when Wordpress::Page
        item.id = blog_api_call("wp.newPage", item.to_struct(:wp), true).to_i
      else
        raise "Unknown item type: #{item}"
      end
    end #publish

    def update(item)
      process_images(item) unless item.images.nil?
      case item
      when Post
        return api_call("metaWeblog.editPost", item.id, @user, @password, item.to_struct(:metaWeblog), item.published)
      when Page
        return api_call("wp.editPage", @id, item.id, @user, @password, item.to_struct(:wp), item.published)
      else
        raise "Unknown item type: #{item}"
      end
    end #update

    def delete(item)
      case item
      when Wordpress::Post
        return api_call("blogger.deletePost", "", item.id, @user, @password, true)
      when Wordpress::Page
        return blog_api_call("wp.deletePage", item.id)
      else
        raise "Unknown item type: #{item}"
      end
    end

    def get_page_list
      page_list = blog_api_call("wp.getPageList").collect do |struct|
        Wordpress::Page.from_struct(:wp, struct)
      end
      # link pages list with each other
      page_list.each do |page|
        page.parent = page_list.find{|p| p.id == page.parent_id} if page.parent_id
      end

      page_list
    end #get_page_list

    def upload_file(file)
      struct = {
        :name => File.basename(file.path),
        :type => MimeMagic.by_magic(file).type,
        :bits => XMLRPC::Base64.new(File.open(file.path, "r").read),
        :overwrite => true
      }
      return blog_api_call("wp.uploadFile", struct)
    end

    private
    def process_images(item)
      doc = Nokogiri::HTML::DocumentFragment.parse(item.content)
      item.images.each do |image|

        raise ArgumentError, "Image not found (path: #{image[:file_path]})" unless File.exist?(image[:file_path])

        basename = File.basename(image[:file_path])
        uploaded_image = upload_file(File.open(image[:file_path], "rb"))
        raise "Image upload failed" if uploaded_image.nil?
        doc.css("img").each do |img|
          img['src'] = uploaded_image['url'] if img['src'].include?(basename)
        end
      end
      item.content = doc.to_html
    end #process_images

    def api_call(method_name, *args)
      begin
        return @client.call(method_name, *args)
      rescue XMLRPC::FaultException
        log.log_exception "Error while calling #{method_name}", $!
        raise APICallException, "Error while calling #{method_name}"
      end
    end #api_call

    def blog_api_call(method_name, *args)
      begin
        return @client.call(method_name, @id, @user, @password, *args)
      rescue XMLRPC::FaultException
        log.log_exception "Error while calling #{method_name}", $!
        raise APICallException, "Error while calling #{method_name}"
      end
    end #call_client
  end
end

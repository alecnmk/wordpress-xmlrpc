require 'xmlrpc/client'
require 'params_check'
require 'base64'
require 'mimemagic'
require 'nokogiri'

module Wordpress
  class Blog
    include ParamsCheck
    include Loggable

    def initialize(params = {})
      @blog_uri = URI.parse(check_param(params, :blog_uri))

      @xmlrpc_path = params[:xmlrpc_path] || "xmlrpc"

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
        Post.from_struct(struct)
      end
    end #recent_posts

    def publish(post)
      doc = Nokogiri::HTML::DocumentFragment.parse(post.content)
      post.images.each do |image|
        image_file = File.open(image[:file_path], "rb")
        file_name = File.basename(image_file.path)

        uploaded_image = upload_file(File.open(image[:file_path], "rb"))

        doc.xpath("img[contains(@src, '#{file_name}')]").each do |img|
          img['src'] = uploaded_image[:url]
        end
      end
      post.content = doc.to_html

      post.id = blog_api_call("metaWeblog.newPost", post.to_struct, true).to_i
      post.published = true
    end #publish

    def update_post(post)
      return api_call("metaWeblog.editPost", post.id, @user, @password, post.to_struct, post.published)
    end #update_post

    def upload_file(file)
      struct = {
        :name => File.basename(file.path),
        :type => MimeMagic.by_magic(file).type,
        :bits => Base64.encode64(file.read),
        :overwrite => true
      }
      return blog_api_call("wp.uploadFile", struct)
    end

    private
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

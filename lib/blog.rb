require 'xmlrpc/client'
require 'params_check'

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
      post.id = blog_api_call("metaWeblog.newPost", post.to_struct, true).to_i
      post.published = true
    end #publish

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

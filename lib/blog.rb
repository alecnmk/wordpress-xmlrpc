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

    def recent_posts(numberOfPosts)
      call_client("metaWeblog.getRecentPosts", numberOfPosts).collect do |struct|
        Post.from_struct(struct)
      end
    end #recent_posts

    def publish(post)
      begin
        post.id = call_client("metaWeblog.newPost", post.to_struct, true).to_i
        post.published = true
        return true
      rescue
        return false
      end
    end #publish

    private
    def call_client(method_name, *args)
      begin
        @client.call(method_name, @id, @user, @password, *args)
      rescue XMLRPC::FaultException
        log.log_exception "Error while calling #{method_name}", $!
        raise APICallException, message
      end
    end #call_client
  end
end

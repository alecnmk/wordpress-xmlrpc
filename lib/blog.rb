require 'xmlrpc/client'
require 'params_check'

module Wordpress
  class Blog
    include ParamsCheck
    include Loggable

    def initialize(params = {})
      @host_uri = URI.parse(check_param(params, :host))

      @id = params[:blog_id] || 0

      @user = check_param(params, :user)

      @password = check_param(params, :password)
    end #initialize

    def publish(post)
      client = XMLRPC::Client.new2(URI.parse("http://localhost/xmlrpc").to_s)
      begin
        post.id = client.call("metaWeblog.newPost", @id, @user, @password, post.to_struct, true).to_i
      rescue XMLRPC::FaultException
        log.error "Error while publishing blog (#{$!})"
        return false
      end
      log.info "Post published successfully"
      return true
    end #publish
  end
end

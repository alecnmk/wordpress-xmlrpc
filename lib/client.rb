module Wordpress
  class Client
    def initialize

    end #initialize

    def publish!(post)
      raise ArgumentError, "Wordpress::Post expected instead of #{post.class}" unless post.kind_of? Wordpress::Post
    end #publish!
  end
end

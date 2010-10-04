$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# to avoid logging while executing tests we need to preload bundled gems
# and set log level to FATAL
require 'rubygems'
require 'bundler/setup'
require 'log4r'
# Log4r::Logger.root.level = Log4r::FATAL

require 'spec'
require 'spec/autorun'

require 'wordpress-xmlrpc'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|

end

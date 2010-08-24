require 'log4r'
require 'pp'

module Loggable
  Log4r::Logger.class_eval do
    define_method :log_exception do |message, exception|
      error {"#{message} (#{exception.message})"}
      debug {exception.backtrace.pretty_inspect}
    end
  end

  def self.included(mod)
    @@log = Log4r::Logger.new mod.name
    @@log.outputters = Log4r::Outputter.stdout
  end #included

  def log
    @@log
  end #log
end

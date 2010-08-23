require 'log4r'

module Loggable
  def self.included(mod)
    @@log = Log4r::Logger.new mod.name
    @@log.outputters = Log4r::Outputter.stdout
  end #included

  def log
    @@log
  end #log
end

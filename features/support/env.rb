require 'rubygems'
require 'bundler'
Bundler.setup

require 'capybara/cucumber'
require 'selenium/webdriver'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'wordpress-xmlrpc'

Capybara.default_driver = :selenium
Capybara.app_host = "http://localhost"
Capybara.default_selector = :css
Capybara.default_wait_time = 3
Capybara.ignore_hidden_elements = true


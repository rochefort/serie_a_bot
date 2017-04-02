$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
ENV["RUBY_ENV"] = "test"
require "rspec/its"
require_relative "../config/boot"
# require_relative '../lib/model'

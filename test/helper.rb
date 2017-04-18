$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
ENV["RUBY_ENV"] = "test"
require_relative "../config/boot"
# require_relative '../lib/model'
require "simplecov"
require "test/unit"
require "test/unit/rr"
require "webmock/test_unit"
SimpleCov.start if ENV["COVERAGE"]

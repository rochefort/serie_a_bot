require 'active_record'

class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  config = YAML.load_file('config/database.yml')
  ActiveRecord::Base.configurations = config
  ActiveRecord::Base.establish_connection(ENV['RUBY_ENV'].to_sym)
end

class RssItem < BaseModel
  belongs_to :rss_site
end

class RssSite < BaseModel
  has_many :rss_items
end

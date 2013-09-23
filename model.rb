require 'active_record'

class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  db_config = YAML.load_file('config/database.yml').symbolize_keys
  ActiveRecord::Base.establish_connection(db_config)
end

class RssItem < BaseModel
end

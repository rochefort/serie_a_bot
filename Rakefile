require_relative 'config/boot.rb'
require_relative 'lib/model'
include ActiveRecord

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :db do
  desc 'データベース、テーブルを作成します'
  task :create do
    Migration.create_table :rss_items do |t|
      t.string     :title
      t.datetime   :pub_date
      t.string     :description
      t.string     :link
      t.datetime   :tweeted_date
      t.references :rss_site
      t.timestamps
    end
    Migration.add_index(:rss_items, [:title, :pub_date], unique:true)

    Migration.create_table :rss_sites do |t|
      t.string :title
      t.string :url
      t.timestamps
    end
  end

  desc 'データベースを削除します'
  task :drop do
    File.unlink(ActiveRecord::Base.connection_config[:database])
  end

  desc 'マスタ初期化（RSSサイトを登録します）'
  task :seed do
    RssSite.destroy_all
    RssSite.create!(title: 'Goal,com', url: 'http://www.goal.com/jp/feeds/news?fmt=rss&ICID=OP')
  end
end

namespace :debug do
  desc 'debug用にtweeted_dateを初期化する'
  task :init_tweeted_date do
    RssItem.all.each do |r|
      r.update_attributes!(tweeted_date: nil)
    end
  end
end

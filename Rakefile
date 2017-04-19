require "rake/testtask"
require_relative "config/boot"
require_relative "lib/model"
include ActiveRecord

task default: :test

desc "Run tests"
ENV["TESTOPTS"] = "-v" unless ENV["TESTOPTS"]
ENV["COVERAGE"] = "true"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/**/test_*.rb"]
  t.verbose = true
  t.warning = false
end

desc "Browse coverage"
task coverage: [:test] do
  sh("open ./coverage/index.html")
end

desc "各種情報を表示"
task :stats do
  puts "RssItem件数: #{RssItem.count}"
  puts "未tweet件数: #{RssItem.where(tweeted_date: nil).size}"
end

namespace :db do
  desc "データベース、テーブルを作成します"
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
    Migration.add_index(:rss_items, [:title, :pub_date], unique: true)

    Migration.create_table :rss_sites do |t|
      t.string :title
      t.string :url
      t.timestamps
    end
  end

  desc "データベースを削除します"
  task :drop do
    File.unlink(ActiveRecord::Base.connection_config[:database])
  end

  desc "schema情報を表示します"
  task :schema do
    tables = ActiveRecord::Base.connection.data_sources
    puts "** tables **"
    puts tables
    puts "-" * 30
    puts "** schema **"
    tables.each do |table|
      puts table
      model = table.classify.safe_constantize
      model.columns_hash.each { |k, v| puts "  #{k} (#{v.type})" }
    end
  end

  desc "マスタ初期化（RSSサイトを登録します）"
  task :seed do
    RssSite.destroy_all
    RssSite.create!(id: 1, title: "Goal,com",   url: "http://www.goal.com/jp/feeds/news?fmt=rss&ICID=OP")
    RssSite.create!(id: 2, title: "SoccerKing", url: "http://www.soccer-king.jp/RSS.rdf")
  end
end

namespace :debug do
  desc "debug用にtweeted_dateを初期化する"
  task :init_tweeted_date do
    RssItem.all.each do |r|
      r.update_attributes!(tweeted_date: nil)
    end
  end
end

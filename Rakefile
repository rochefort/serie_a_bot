require './model'

namespace :db do
  desc 'データベース、テーブルを作成します'
  task :create do
    ActiveRecord::Migration.create_table :rss_items do |t|
      t.string :title
      t.datetime :pub_date
      t.string :description
      t.string :link
      t.datetime :tweeted_date
      t.timestamps
    end
    ActiveRecord::Migration.add_index(:rss_items, [:title, :pub_date], unique:true)
  end

  desc 'データベースを削除します'
  task :drop do
    File.unlink(ActiveRecord::Base.connection_config[:database])
  end
end

namespace :debug do
  desc 'debug用にtweeted_dateを初期化する'
  task :init_tweeted_date do
    RssItems.all.each do |r|
      r.update_attributes!(tweeted_date: nil)
    end
  end
end

require 'sqlite3'

DB_FILE = 'serie_a_bot.db'

namespace :db do
  desc 'データベース、テーブルを作成します'
  task :create do
    db = SQLite3::Database.new(DB_FILE)
    sql = <<-SQL
      CREATE TABLE rss_items (
        title varchar2,
        pub_date text,
        description varchar2,
        link varchar2,
        tweeted_date text,
        PRIMARY KEY(title, pub_date)
      );
    SQL
    db.execute(sql)
  end

  desc 'データベースを削除します'
  task :drop do
    File.unlink(DB_FILE)
  end
end

namespace :debug do
  desc 'debug用にtweeted_dateを初期化する'
  task :init_tweeted_date do
    sql = 'UPDATE rss_items SET tweeted_date = null'
    db = SQLite3::Database.new(DB_FILE)
    db.execute(sql)
  end
end

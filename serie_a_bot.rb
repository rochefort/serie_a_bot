#!/usr/bin/env ruby
require 'rss'

require 'httparty'
require 'json'
require 'sanitize'
require 'sqlite3'
require 'twitter'

class SerieABot
  DEBUG = false

  def initialize
    @db = SQLite3::Database.new('serie_a_bot.db')
    yaml = YAML.load_file('settings.yaml')
    Twitter.configure do |config|
      config.consumer_key = yaml['twitter']['consumer_key']
      config.consumer_secret = yaml['twitter']['consumer_secret']
      config.oauth_token = yaml['twitter']['oauth_token']
      config.oauth_token_secret = yaml['twitter']['oauth_token_secret']
    end
  end

  def crawl
    rss = RSS::Parser.parse('http://www.goal.com/jp/feeds/news?fmt=rss&ICID=OP')
    sql = 'REPLACE INTO rss_items(title, pub_date, description, link, tweeted_date) ' +
          'VALUES(?, ?, ?, ?, (SELECT tweeted_date FROM rss_items WHERE title = ? AND pub_date = ?))'
    @db.transaction do
      rss.items.each do |item|
        title = item.title
        pub_date = ymdhms(item.date)
        description = Sanitize.clean(item.description).strip
        if about_serie_a?(title, description)
          @db.execute(sql, title, pub_date, description, item.link, title, pub_date)
        else
          if DEBUG
            puts "----"
            puts title
            puts description
          end
        end
      end
    end
  end

  def tweet
    sel_sql = 'SELECT title, pub_date, description, link FROM rss_items WHERE tweeted_date is null ORDER BY pub_date, title LIMIT 1'
    upd_sql = 'UPDATE rss_items SET tweeted_date = ? where title = ? AND pub_date = ?'

    @db.execute(sel_sql) do |row|
      begin
        title = row[0]
        pub_date = row[1]
        description = row[2]
        link = URI.decode(row[3])
        Twitter.update("#{title}\n#{description}\n#{url_shortner(link)}")
        @db.execute(upd_sql, ymdhms(Time.now), title, pub_date)
      rescue Twitter::Error::Forbidden => e
        @db.execute(upd_sql, ymdhms(Time.now), title, pub_date)
      rescue
        # do nothing
      end
    end
  end

  private
    def ymdhms(time)
      time.strftime("%Y-%m-%d %H:%M:%S")
    end

    def about_serie_a?(*words)
      File.open('whitelist.txt').readlines.map(&:strip).any? do |keyword|
        words.join.include?(keyword)
      end
    end

    # Google API Shortner response:
    # {
    #  "kind": "urlshortener#url",
    #  "id": "http://goo.gl/CfPqZs",
    #  "longUrl": "http://rochefort.hatenablog.com/"
    # }
    def url_shortner(url)
      res = HTTParty.post('https://www.googleapis.com/urlshortener/v1/url',
        :body => { :longUrl => url }.to_json,
        :headers => { 'Content-Type' => 'application/json' } )

      (res.code == 200) ? res["id"] : url
    end
end

if __FILE__ == $0
  s = SerieABot.new
  s.crawl
  s.tweet
end

#!/usr/bin/env ruby
require 'rss'

require 'httparty'
require 'json'
require 'sanitize'
require 'sqlite3'
require 'twitter'

class SerieABot

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
    sql = 'REPLACE INTO rss_items(title, pub_date, description, link) VALUES(?, ?, ?, ?)'
    @db.transaction do
      rss.items.each do |item|
        @db.execute(sql, item.title, ymdhms(item.date), item.description, item.link)
      end
    end
  end

  def tweet
    sel_sql = 'SELECT title, pub_date, description, link FROM rss_items WHERE tweeted_date is null ORDER BY pub_date, title LIMIT 1'
    upd_sql = 'UPDATE rss_items SET tweeted_date = ? where title = ? AND pub_date = ?'
    @db.execute(sel_sql) do |row|
      title = row[0]
      pub_date = row[1]
      description = Sanitize.clean(row[2]).strip
      link = URI.decode(row[3])
      Twitter.update("#{title}\n#{description}\n#{url_shortner(link)}")
      @db.execute(upd_sql, ymdhms(Time.now), title, pub_date)
    end
  end

  private
    def ymdhms(time)
      time.strftime("%Y-%m-%d %H:%M:%S")
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

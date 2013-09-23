#!/usr/bin/env ruby
require './model'
require 'rss'

require 'httparty'
require 'json'
require 'sanitize'
require 'sqlite3'
require 'twitter'

class SerieABot
  DEBUG = false

  def initialize
    yaml = YAML.load_file('config/settings.yaml')
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

    RssItem.transaction do
      rss.items.each do |item|
        title = item.title
        pub_date = ymdhms(item.date)
        description = Sanitize.clean(item.description).strip
        if about_serie_a?(title, description)
          st = RssItem.connection.raw_connection.prepare(sql)
          st.execute(title, pub_date, description, item.link, title, pub_date)
          st.close
          puts title if DEBUG
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
    RssItem.where(tweeted_date: nil).order('pub_date, title').limit(1).first.tap do |r|
      begin
        Twitter.update("#{r.title}\n#{r.description}\n#{url_shortner(r.link)}")
        r.update_attributes(tweeted_date: ymdhms(Time.now), title: r.title, pub_date: r.pub_date)
      rescue Twitter::Error::Forbidden => e
        # Tweet二重登録時には、DBの更新だけ行う
        r.update_attributes(tweeted_date: ymdhms(Time.now), title: r.title, pub_date: r.pub_date)
      rescue => e
        # do nothing
        p e if DEBUG
      end
    end
  end

  private
    def ymdhms(time)
      time.strftime("%Y-%m-%d %H:%M:%S")
    end

    def about_serie_a?(*words)
      File.open('config/whitelist.txt').readlines.map(&:strip).any? do |keyword|
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

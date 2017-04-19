#!/usr/bin/env ruby
require_relative "../config/boot"

require "json"
require "rss"
require "active_support/core_ext/string/filters"
require "sanitize"
require "twitter"

require_relative "model"
require_relative "google_shortner"

class SerieABot
  MAX_TWEET_SIZE = 140
  # url形式だと23bytesとして扱われる。
  TWEET_URL_SIZE = 23

  def initialize
    settings = YAML.load_file(File.join(PROJECT_ROOT, "config/settings.yml"))
    @client = Twitter::REST::Client.new do |c|
      c.consumer_key        = settings["twitter"]["consumer_key"]
      c.consumer_secret     = settings["twitter"]["consumer_secret"]
      c.access_token        = settings["twitter"]["access_token"]
      c.access_token_secret = settings["twitter"]["access_token_secret"]
    end
    @whitelist = File.open("config/whitelist.txt").readlines.map(&:strip)
    @whitelist.delete("")
    @debug = !ENV["DEBUG"].nil?
  end

  def crawl
    sql = "REPLACE INTO rss_items(title, pub_date, description, link, tweeted_date, rss_site_id) " +
          "VALUES(?, ?, ?, ?, (SELECT tweeted_date FROM rss_items WHERE title = ? AND pub_date = ?), ?)"

    RssSite.all.each do |site|
      # SoccorKing の RSSがinvalidであるため、validationなしでparseを行う
      rss = RSS::Parser.parse(site.url, false)
      RssItem.transaction do
        rss.items.each do |item|
          title = item.title
          pub_date = ymdhms(item.date)
          description = Sanitize.clean(item.description).strip.gsub(/\A　*/, "")
          is_serie_a = about_serie_a?(title, description)
          if is_serie_a
            st = RssItem.connection.raw_connection.prepare(sql)
            st.execute(title, pub_date, description, item.link, title, pub_date, site.id)
            st.close
          end

          if @debug
            header = "---- #{site.title}"
            header << " ** seriea **" if is_serie_a
            puts header
            puts title
            puts
            # puts description
          end
        end
      end
    end
  end

  def tweet_rss
    RssItem.where(tweeted_date: nil).order("pub_date, title").limit(1).first.tap do |r|
      begin
        @client.update(generate_tweet(r))
        r.update_attributes(tweeted_date: ymdhms(Time.now), title: r.title, pub_date: r.pub_date)
      rescue Twitter::Error::Forbidden => e
        # Tweet二重登録時には、DBの更新だけ行う
        r.update_attributes(tweeted_date: ymdhms(Time.now), title: r.title, pub_date: r.pub_date)
      rescue => e
        # do nothing
        p e if @debug
      end
    end
  end

  def tweet(msg)
    @client.update(msg)
  rescue => e
    p e if @debug
  end

  private

    def generate_tweet(rss_item)
      r = rss_item
      title = "[#{r.rss_site.title}]#{r.title}"
      link  = "#{GoogleShortner.shorten(r.link)}"
      # title, desc, link の改行数
      line_feed_number = 2
      desc_size = MAX_TWEET_SIZE - TWEET_URL_SIZE - title.size - line_feed_number
      desc = "#{r.description}\n".truncate(desc_size)
      "#{title}\n#{desc}\n#{link}"
    end

    def ymdhms(time)
      time.strftime("%Y-%m-%d %H:%M:%S")
    end

    def about_serie_a?(*words)
      @whitelist.any? do |keyword|
        words.join.include?(keyword)
      end
    end
end

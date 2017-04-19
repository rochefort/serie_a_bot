#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))

require "mechanize"
require "serie_a_bot"

Product = Struct.new(:title, :score, :link)

class DailyTweet
  AMAZON_BASE_URL = "https://www.amazon.co.jp"
  AMAZON_DAILY_URL = "#{AMAZON_BASE_URL}/Kindle%E6%97%A5%E6%9B%BF%E3%82%8F%E3%82%8A/b?ie=UTF8&node=3338926051"
  AFFILIATE_TAG = "serie_a_bot-22"

  def initialize
    @agent = Mechanize.new
  end

  def run
    link = scrape_link
    return unless link
    product = scrape_product(link)
    msg = genereate_tweet(product)
    tweet(msg)
  end

  private
    def scrape_link
      page = @agent.get(AMAZON_DAILY_URL)
      sleep 1
      page.search(".acs-bgtext-imageblock a").attr("href").value
    end

    def scrape_product(relative_link)
      link = "#{AMAZON_BASE_URL}#{relative_link}"
      p link
      page = @agent.get(link)
      sleep 1
      title = page.search(".a-size-extra-large").text()
      score = page.search(".a-icon.a-icon-star.a-star-4-5 .a-icon-alt")[0].text()
      Product.new(title, score, link)
    end

    def genereate_tweet(product)
      [
        "今日のKindle日替わりセール",
        product.title,
        "（#{product.score}）",
        "#{product.link}?tag=#{AFFILIATE_TAG}"
      ].join("\n")
    end

    def tweet(msg)
      s = SerieABot.new
      s.tweet(msg)
    end
end

if $0 == __FILE__
  DailyTweet.new.run
end

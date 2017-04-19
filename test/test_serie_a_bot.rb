require_relative "helper"
require "serie_a_bot"

class TestSerieABot < Test::Unit::TestCase
  setup do
    @bot = SerieABot.new
  end

  # privates
  sub_test_case "#generate_tweet" do
    setup do
      stub(GoogleShortner).shorten { "https://goo.gl/U98s" }
    end

    data(
      "normal" => [
        "[site_title]title\ndescription\n\nhttps://goo.gl/U98s",
        "title",
        "description"
      ],
      "140 characters" => [
        "[site_title]title\ndescription_is_97_9_123456789_123456789_123456789_123456789_123456789_123456789_123456789_1234567\n\nhttps://goo.gl/U98s",
        "title",
        "description_is_97_9_123456789_123456789_123456789_123456789_123456789_123456789_123456789_1234567"
      ],
      "141 characters" => [
        "[site_title]title\ndescription_is_98_9_123456789_123456789_123456789_123456789_123456789_123456789_123456789_12345...\nhttps://goo.gl/U98s",
        "title",
        "description_is_98_9_123456789_123456789_123456789_123456789_123456789_123456789_123456789_12345678"
      ]
    )
    def test_generate_tweet(data)
      expected, title, description = data
      rss_item = stub_rss_item(title, description)
      assert_equal expected, @bot.send(:generate_tweet, rss_item)
    end
  end

  def test_ymdhms
    expected_time = "2017-04-16 15:43:02"
    time = Time.parse(expected_time)
    assert_equal expected_time, @bot.send(:ymdhms, time)
  end

  sub_test_case "#about_serie_a?" do
    data(
      "incorrect singlebyte word" => [true, "inter", ["インテル", "イタリア", "inter"]],
      "incorrect multibytes word" => [true, "インテル悲願のスクデッド", ["インテル", "イタリア"]],
      "whitelist is empty" => [false, "インテル", []],
      "not found" =>          [false, "インテル", ["フロンターレ", "長友"]]
    )
    def test_about_serie_a(data)
      expected, target, whitelist = data
      @bot.instance_variable_set(:@whitelist, whitelist)
      assert_equal expected, @bot.send(:about_serie_a?, target)
    end
  end

  private

    # TODO: use fixtures
    def stub_rss_item(title, description)
      rss_site = RssSite.new(title: "site_title")
      rss_item = RssItem.new(title: title, link: "http://www.example.com", description: description)
      rss_item.rss_site = rss_site
      rss_item
    end
end

require_relative "helper"
require "serie_a_bot"

class TestSerieABot < Test::Unit::TestCase
  def setup
    @bot = SerieABot.new
  end

  # privates
  def test_ymdhms
    expected_time = "2017-04-16 15:43:02"
    time = Time.parse(expected_time)
    assert_equal expected_time, @bot.send(:ymdhms, time)
  end

  sub_test_case "about_serie_a?" do
    data(
      "incorrect singlebyte word" => [true, "inter", ["インテル", "イタリア", "inter"]],
      "incorrect multibytes word" => [true, "インテル悲願のスクデッド", ["インテル", "イタリア"]],
      "whitelist is empty" => [false, "インテル", []],
      "not found" =>          [false, "インテル", ["フロンターレ", "長友"]]
    )
    def test_whitelist_is_empty(data)
      expected, target, whitelist = data
      @bot.instance_variable_set(:@whitelist, whitelist)
      assert_equal expected, @bot.send(:about_serie_a?, target)
    end
  end
end

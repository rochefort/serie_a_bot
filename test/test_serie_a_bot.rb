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
    data("empty" => [false, "インテル"])
    def test_whitelist_is_empty(data)
      expected, target = data
      @bot.instance_variable_set(:@whitelist, [])
      assert_equal expected, @bot.send(:about_serie_a?, target)
    end
  end
end

require_relative "helper"
require "serie_a_bot"

class TestGoogleShortner < Test::Unit::TestCase
  sub_test_case "shorten" do
    sub_test_case "when correct_response" do
      def test_shorten_is_correct_response
        stub_request(:post, GoogleShortner::API_BASE_URL).to_return(status: 200, body: stub_correct_response_body)
        assert_equal "https://goo.gl/U98s", GoogleShortner.shorten("http://www.example.com")
      end
    end

    sub_test_case "when incorrect_response" do
      def test_shorten_is_incorrect_response_status_500
        stub_request(:post, GoogleShortner::API_BASE_URL).to_return(status: 500, body: stub_correct_response_body)
        assert_equal "http://www.example.com", GoogleShortner.shorten("http://www.example.com")
      end

      def test_shorten_is_incorrect_response_body
        stub_request(:post, GoogleShortner::API_BASE_URL).to_return(status: 200, body: {}.to_json)
        assert_equal "http://www.example.com", GoogleShortner.shorten("http://www.example.com")
      end
    end
  end

  private

    def stub_correct_response_body
      body = {
        "kind": "urlshortener#url",
        "id": "https://goo.gl/U98s",
        "longUrl": "http://www.example.com"
      }
      body.to_json
    end
end

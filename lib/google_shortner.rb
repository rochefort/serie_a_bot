require "json"
require "httpclient"

class GoogleShortner
  API_BASE_URL = "https://www.googleapis.com/urlshortener/v1/url"
  # Google API Shortner
  # Response:
  # {
  #  "kind": "urlshortener#url",
  #  "id": "http://goo.gl/CfPqZs",
  #  "longUrl": "http://rochefort.hatenablog.com/"
  # }
  #
  # Error Response:
  # {"error"=>
  #   {"errors"=>
  #     [{"domain"=>"usageLimits",
  #       "reason"=>"dailyLimitExceededUnreg",
  #       "message"=>
  #       "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup.",
  #       "extendedHelp"=>"https://code.google.com/apis/console"}],
  #     "code"=>403,
  #     "message"=>
  #     "Daily Limit for Unauthenticated Use Exceeded. Continued use requires signup."
  #   }
  # }

  def self.shorten(url)
    client = HTTPClient.new
    res = client.post(API_BASE_URL,
      body: { longUrl: url }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
    body = JSON.parse(res.body)
    return url unless res.code == 200
    body["id"] || url
  end
end

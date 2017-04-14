require "json"
require "httparty"

class GoogleShortner
  API_URL = "https://www.googleapis.com/urlshortener/v1/url"
  # Google API Shortner
  # response:
  # {
  #  "kind": "urlshortener#url",
  #  "id": "http://goo.gl/CfPqZs",
  #  "longUrl": "http://rochefort.hatenablog.com/"
  # }
  def self.shorten(url)
    res = HTTParty.post(API_URL,
      body: { longUrl: url }.to_json,
      headers: { "Content-Type" => "application/json" })

    (res.code == 200) ? res["id"] : url
  end
end

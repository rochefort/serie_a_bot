require "spec_helper"
require "serie_a_bot"

describe "SerieABot" do
  before do
    @settings = { "twitter" => {
      "consumer_key"        => "consumer_key",
      "consumer_secret"     => "consumer_secret",
      "access_token"        => "access_token",
      "access_token_secret" => "access_token_secret"
    } }
    allow(YAML).to receive(:load_file).and_return(@settings)
    @bot = SerieABot.new
  end

  describe "Initializing settings" do
    subject { @bot.instance_variable_get(:@client) }
    its(:consumer_key)        { should == @settings["twitter"]["consumer_key"] }
    its(:consumer_secret)     { should == @settings["twitter"]["consumer_secret"] }
    its(:access_token)        { should == @settings["twitter"]["access_token"] }
    its(:access_token_secret) { should == @settings["twitter"]["access_token_secret"] }
  end
end

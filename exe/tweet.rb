#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))

require "serie_a_bot"
s = SerieABot.new
s.tweet_rss

#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))

require "serie_a_bot"
s = SerieABot.new
msg = File.read(File.join(PROJECT_ROOT, "config/regular_msg.txt"))
s.tweet(msg)

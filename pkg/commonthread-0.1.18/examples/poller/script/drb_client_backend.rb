#!/usr/bin/env ruby

require 'drb'

pwd = File.dirname(__FILE__)

if ARGV[0] == '--help'
   print "Usage: script/drb_client <bind_ip> <port>"
   exit
end

bind_ip = ARGV[0] || 'localhost'
port = ARGV[1] || 5750

connect_string = "druby://#{bind_ip}:#{port}"
puts "Connecting to #{connect_string}"
DRb.start_service
c = controllers = DRbObject.new(nil, connect_string)

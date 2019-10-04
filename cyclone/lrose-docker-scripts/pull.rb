#!/usr/bin/env ruby

# Query docker for the status of the lrose-cyclone image
# Print out the pull count
#
# To be run by cron every day at 11:59pm

require 'json'
require 'net/http'
require 'uri'
require 'date'

uri = URI.parse("https://hub.docker.com/v2/repositories/nsflrose/lrose-cyclone/")
response = Net::HTTP.get_response(uri)

if response.code.to_i != 200
  puts "Error: #{response.code}"
  exit 1
end

my_hash = JSON.parse(response.body)
puts "#{Time.now.strftime("%m/%d/%Y")}: #{my_hash["pull_count"]}"


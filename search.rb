#!/usr/bin/env ruby
require 'epitools'
# require 'elasticsearch'

require_relative "file_index"

pp FileIndex.new.search(ARGV.join " ")
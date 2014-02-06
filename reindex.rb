#!/usr/bin/env ruby
require 'epitools'
require_relative 'file_index'

index = FileIndex.new(log: true)

# index.reset!

args = ARGV
# args << "~/Research/Computer Science"

args.each do |arg|
  Path[arg].ls_r.each do |path|
    puts "<14>#{path}".colorize
    index.add path
  end
end
#!/usr/bin/env ruby
require 'yaml'
require 'smart_colored/extend'

class Array
  def ^(other)
    result = dup
    other.each{|e| result.include?(e) ? result.delete(e) : result.push(e) }
    result
  end unless method_defined?(:^)
  alias diff ^ unless method_defined?(:diff)
end

def all_keys(hash)
  res = hash.keys
  hash.values.each{|x| res += all_keys(x) if x.is_a? Hash}
  res
end

trads = {}
langs = []
ARGV.each do |x|
  content = YAML.load_file(x)
  langs << content.keys.first
  trads[langs.last] = all_keys content[langs.last]
end

missing = []
prev = []
trads.map{|k,v| v.to_a.uniq.map{|x| x.strip}.sort}.each do |x|
  missing = x ^ prev if !prev.empty?
  prev = x
end

langs.each do |x|
  missing.each do |y|
    puts "#{y.red.bold} not found in #{x.red.bold}" if !trads[x].include? y
  end
end

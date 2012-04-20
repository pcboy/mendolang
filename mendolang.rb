#!/usr/bin/env ruby
#
#          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                  Version 2, December 2004
#
#  Copyright (C) 2004 Sam Hocevar
#  14 rue de Plaisance, 75014 Paris, France
#  Everyone is permitted to copy and distribute verbatim or modified
#  copies of this license document, and changing it is allowed as long
#  as the name is changed.
#  DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#
#
#  David Hagege <david.hagege@gmail.com>
#

require 'yaml'
require 'smart_colored/extend'

if ARGV.empty?
  $stderr.puts "Usage: #{$0} config/locales/*.yml"
  exit
end

no_colors = ARGV[0] == '--no-colors'
ARGV.shift if no_colors

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
trads.map{|k,v| v.to_a.map{|x| x.strip}.sort}.each do |x|
  missing += (x ^ prev) if !prev.empty?
  prev = x
end

output = []
langs.each do |x|
  missing.each do |y|
    no_colors ?  (key, lang = y, x) : (key,lang = y.red.bold, x.red.bold)
    output << "#{key} not found in #{lang}" if !trads[x].include? y
  end
end
puts output.uniq!.sort

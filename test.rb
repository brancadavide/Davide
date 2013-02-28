#!/usr/bin/env ruby

a = "122.459.754."

puts a.split(".").last(2).reverse

puts a.split(".").each { |e| puts e  }

text = File.new('test.txt','w')

text.puts "Test!"

text.close
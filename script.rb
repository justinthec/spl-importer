#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_1/Round_Robin'))

matches = []
doc.css('#mw-content-text div[style="display:inline-block; vertical-align: top; margin: 0 0 0 0;padding-right:2em;"]').each do |match|
	if (match.content.strip != "") then
		matches.push(match)
	end
end

matches.each do |match|
	team1 = match.css('table')[0].css('tr td')[0].content.gsub("\302\240", ' ').strip
	team2 = match.css('table')[0].css('tr td')[3].content.gsub("\302\240", ' ').strip
	time = match.css('table')[1].css('tr th span[style="margin-left:40px; font-size:85%; line-height:90%;"]').text
	puts "#{team1} vs #{team2} at #{time}"
end

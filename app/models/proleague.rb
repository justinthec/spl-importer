require 'open-uri'

class Proleague
	# Pages array to store the pages we will pull the matches from
	@@pages = [
		'http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_3',
		'http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_3/Round_Robin'
	]

	def self.matches
		# Matches array to store the matches we will add to the Calendar
		matches = []

		@@pages.each do |page|
		  # Open Liquipedia Page for parsing the matches
		  doc = Nokogiri::HTML(open(page))

		  # Parse through the HTML for the match info and populate the matches array
		  doc.css('#mw-content-text div[style="display:inline-block; vertical-align: top; margin: 0 0 0 0;padding-right:2em;"]').each do |match|
		    if (match.content.strip != "") then
		    	match_table_row = match.css('table')[0].css('tr td')
		    	time_container = match.css('table')[1].css('tr th span').select{|link| link['style'] =~ /margin-left:.*40px;.*font-size:.*85%;.*line-height:.*90%;/}[0]	

		      team1 = match_table_row[0].content.gsub("\302\240", ' ').strip
		      team2 = match_table_row[3].content.gsub("\302\240", ' ').strip
		      time = time_container.text
          timezone = time_container.css('abbr')[0]['data-tz']

		      time_segments = time.split
		      year = time_segments[2]
		      month = Date::MONTHNAMES.index(time_segments[0])
		      date = time_segments[1].gsub(/,/, '')
		      hour = time_segments[3].slice(0..1)
		      min = time_segments[3].slice(3..4)

		      match = ProleagueMatch.new(team1, team2, year, month, date, hour, min, timezone)
		      if(match.endtime > DateTime.now) then
		        matches.push(match)
		      end
		    end
		  end
		end

		return matches
	end

end
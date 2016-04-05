require 'open-uri'

class Proleague
  # Pages array to store the pages we will pull the matches from
  @@pages = [
    #'http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_3',
    #'http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_4/Round_Robin',
    #'http://wiki.teamliquid.net/starcraft2/2016_Proleague/Round_1/Round_Robin',
    'http://wiki.teamliquid.net/starcraft2/2016_Proleague/Round_2/Round_Robin'
  ]

  def self.matches
    # Matches array to store the matches we will add to the Calendar
    matches = []

    @@pages.each do |page|
      # Open Liquipedia Page for parsing the matches
      doc = Nokogiri::HTML(open(page))

      # Parse through the HTML for the match info and populate the matches array
      doc.css('div[style="display:inline-block; vertical-align: top; margin: 0 0 0 0;padding-right:2em;"]').each do |match|
        if (match.content.strip != "")
          match_table_row = match.css('table')[0].css('tr td')
          time_container = match.css('table')[1].css('tr th span').select{|link| link['style'] =~ /margin-left:.*40px;.*font-size:.*85%;.*line-height:.*90%;/}[0]

          team1 = match_table_row[0].css('span[class="team-template-text"] a').text.gsub("\302\240", ' ').strip
          team2 = match_table_row[3].css('span[class="team-template-text"] a').text.gsub("\302\240", ' ').strip
          time = time_container.text
          timezone = time_container.css('abbr')[0]['data-tz']

          year = /\d{4}/.match(time)[0] # \d{4}
          month = Date::MONTHNAMES.index(/[A-Z][a-z]+/.match(time)[0]) # [A-Z][a-z]+
          date = /\s([1-9]|[1-2][0-9]|3[0-1])(\s|\,)/.match(time)[0].gsub(/,/, '').strip # \s([1-9]|[1-2][0-9]|3[0-1])(\s|\,)
          hour_min = /(\d{2}\:\d{2})|(\s\d:\d{2})/.match(time)[0].strip # (\d{2}\:\d{2})|(\s\d:\d{2})
          hour = hour_min.split(':')[0]
          min = hour_min.split(':')[1]

          match = ProleagueMatch.new(team1, team2, year, month, date, hour, min, timezone)
          matches.push(match)
        end
      end
    end

    return matches
  end

end

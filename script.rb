#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

require 'json'
require 'date'

# Open Liquipedia Page for parsing the matches
doc = Nokogiri::HTML(open('http://wiki.teamliquid.net/starcraft2/2015_Proleague/Round_1/Round_Robin'))

# Matches array to store the matches we will add to the Calendar
matches = []

# Match class
class Match
	def initialize(team1, team2, printable_time, startyear, startmonth, startdate, starthour, startmin)
		@team1 = team1
		@team2 = team2
		@printable_time = printable_time
		@startyear = Integer(startyear)
		@startmonth = Integer(startmonth)
		@startdate = Integer(startdate)
		@starthour = Integer(starthour)
		@startmin = Integer(startmin)
	end
	def team1
		@team1
	end
	def team2
		@team2
	end
	def print
		puts "#{@team1} vs #{@team2} at #{@printable_time}"
	end
	def startyear
		@startyear
	end
	def startmonth
		@startmonth
	end
	def startdate
		@startdate
	end
	def starthour
		@starthour
	end
	def startmin
		@startmin
	end
end

# Parse through the HTML for the match info and populate the matches array
doc.css('#mw-content-text div[style="display:inline-block; vertical-align: top; margin: 0 0 0 0;padding-right:2em;"]').each do |match|
	if (match.content.strip != "") then
		team1 = match.css('table')[0].css('tr td')[0].content.gsub("\302\240", ' ').strip
		team2 = match.css('table')[0].css('tr td')[3].content.gsub("\302\240", ' ').strip
		time = match.css('table')[1].css('tr th span[style="margin-left:40px; font-size:85%; line-height:90%;"]').text

		time_array = time.split
		year = time_array[2]
		month = Date::MONTHNAMES.index(time_array[0])
		date = time_array[1].gsub(/,/, '')
		hour = time_array[3].slice(0..1)
		min = time_array[3].slice(3..4)

		match = Match.new(team1, team2, time, year, month, date, hour, min)
		matches.push(match)
	end
end

puts "#{matches.count} Matches found..."

# Initialize the client.
client = Google::APIClient.new(
	:application_name => 'SPL Importer',
	:application_version => '1.0.0'
)

# Initialize Google Calendar API. Note this will make a request to the
# discovery service every time, so be sure to use serialization
# in your production code. Check the samples for more details.
calendar = client.discovered_api('calendar', 'v3')

# Load client secrets from your client_secrets.json.
client_secrets = Google::APIClient::ClientSecrets.load

# Run installed application flow. Check the samples for a more
# complete example that saves the credentials between runs.
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => client_secrets.client_id,
  :client_secret => client_secrets.client_secret,
  :scope => ['https://www.googleapis.com/auth/calendar']
)
client.authorization = flow.authorize

# Get list of calendars
list_of_calendars = client.execute(
  :api_method => calendar.calendar_list.list,
)

puts "Google API authenticated..."

# Deletes SPL Calendar if it already exists
list_of_calendars.data.items.each do |calendar_item|
	if (calendar_item.summary == "Starcraft 2 Proleague") then
		puts "SPL Calendar found, deleting..."
		delete_spl = client.execute(
			:api_method => calendar.calendars.delete,
			:parameters => {'calendarId' => calendar_item.id}
		)
		puts "SPL Calendar deleted..."
	end
end

# Creates new SPL Calendar
spl_calendar = {
	'summary' => "Starcraft 2 Proleague",
	'timeZone' => "Asia/Seoul"
}

create_spl = client.execute(
	:api_method => calendar.calendars.insert,
	:body => JSON.dump(spl_calendar),
	:headers => {'Content-Type' => 'application/json'}
)

puts "SPL Calendar created..."

# Save SPL Calendar ID for creating events
spl_calendar_id = create_spl.data.id

puts "Importing Matches..."

# Creates Events for each of the Matches
matches.each do |match|
	match_event = {
		'summary' => "#{match.team1} vs #{match.team2}",
		'start' => {
			'dateTime' => DateTime.new(match.startyear, match.startmonth, match.startdate, match.starthour, match.startmin, 0, '+9').to_s,
			'timeZone' => "Asia/Seoul"
		},
		'end' => {
			'dateTime' => DateTime.new(match.startyear, match.startmonth, match.startdate, match.starthour+1, match.startmin, 0, '+9').to_s,
			'timeZone' => "Asia/Seoul"
		}
	}

	create_match = client.execute(
		:api_method => calendar.events.insert,
		:parameters => {'calendarId' => spl_calendar_id},
		:body => JSON.dump(match_event),
		:headers => {'Content-Type' => 'application/json'}
	)

	match.print
end

# Done
puts "Match Import Complete!"

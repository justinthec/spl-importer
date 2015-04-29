namespace :hosted_calendar do
  desc "Updates the hosted calendar on the Google Calendar with new data"
  task :update => :environment do
    puts "Updating Hosted Calendar..."
    bench_start = Time.now

    @matches = Proleague.matches

    puts "#{@matches.count} Matches found..."
    if @matches.any?
      # Require the client
      require 'google/api_client'

      # Initialize the client.
      client = Google::APIClient.new(
        :application_name => 'SPL Importer',
        :application_version => '1.0.0'
      )

      # Authenticate our client with the token for our Hosted Calendar
      client.authorization.access_token = Token.last.fresh_token

      # Initialize Google Calendar API. Note this will make a request to the
      # discovery service every time, so be sure to use serialization
      # in your production code. Check the samples for more details.
      calendar = client.discovered_api('calendar', 'v3')

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

      # Create Batch Request
      batch = Google::APIClient::BatchRequest.new

      # Creates Events for each of the Matches
      @matches.each do |match|
        match_event = {
          'summary' => "#{match.team1} vs #{match.team2}",
          'start' => {
            'dateTime' => match.starttime.to_s,
            'timeZone' => "Asia/Seoul"
          },
          'end' => {
            'dateTime' => match.endtime.to_s,
            'timeZone' => "Asia/Seoul"
          }
        }

        post_match_request = {
          :api_method => calendar.events.insert,
          :parameters => {'calendarId' => spl_calendar_id},
          :body => JSON.dump(match_event),
          :headers => {'Content-Type' => 'application/json'}
        }

        batch.add(post_match_request)
        match.print
      end

      # Send Batch Request
      client.execute(batch)
    end

    # Done
    puts "Hosted Calendar Update Complete!"
    puts "Elapsed time: #{Time.now - bench_start}"
  end
end
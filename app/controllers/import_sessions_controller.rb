class ImportSessionsController < ApplicationController
  def index
  end

  def failure
    # Save Import in database
    ImportAttempt.create(succeeded: false, match_count: 0, time: DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)').to_s)
  end

  def success
    bench_start = Time.now

    auth = request.env['omniauth.auth']
    email = auth['info']['email']
    auth = auth['credentials']

    if email == "starcraft2calendar@gmail.com"
      puts "Hosted Calendar Detected..."
      token = Token.find_or_initialize_by(email: email)
      token.update(
        access_token: auth['token'],
      expires_at: Time.at(auth['expires_at']).to_datetime)
      puts "Access Token and Expiry Date Updated..."
      unless token.refresh_token.present?
        token.update(
          refresh_token: auth['refresh_token'])
        puts "Refresh Token Stored... New Token!"
      end
      render :nothing => true, :status => 200
      return
    end

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

      # Authenticate our client with the token we recieved from the Google API
      client.authorization.access_token = auth['token']

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

    # Save Import in database
    ImportAttempt.create(succeeded: true, match_count: @matches.count, api_token: auth.token, time: DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)').to_s)

    # Done
    puts "Match Import Complete!"
    puts "Elapsed time: #{Time.now - bench_start}"
  end
end
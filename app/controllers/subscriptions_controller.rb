class SubscriptionsController < ApplicationController

  def new
    ImportAttempt.create(succeeded: true, match_count: 0, time: DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)').to_s)
    redirect_to 'https://www.google.com/calendar/render?cid=hhlra37v3ok5968in4lui1a9i0%40group.calendar.google.com'
  end
end

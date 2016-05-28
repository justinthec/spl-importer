class ProleagueMatch < ActiveRecord::Base
  attr_reader :team1, :team2, :starttime, :endtime

  def initialize(team1, team2, startyear, startmonth, startdate, starthour, startmin, timezone)
    @team1 = team1
    @team2 = team2

    startyear = startyear.to_i
    startmonth = startmonth.to_i
    startdate = startdate.to_i
    starthour = starthour.to_i
    startmin = startmin.to_i

    @starttime = DateTime.new(startyear, startmonth, startdate, starthour, startmin, 0, timezone)
    @endtime = DateTime.new(startyear, startmonth, startdate, starthour+1, startmin, 0, timezone)
    @printable_time = @starttime.strftime('%B %-d, %Y %k:%M %Z')
  end

  def print
    puts self.info
  end

  def info
    return "#{@team1} vs #{@team2} on #{@printable_time}"
  end
end
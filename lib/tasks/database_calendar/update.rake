namespace :database_calendar do
  desc "Updates the local calendar in the database with new data"
  task :update => :environment do
    @matches = Proleague.matches

    puts "#{@matches.count} Matches found..."
    if @matches.any?
      @matches.each do |match|
        match.print
      end
    end

    # Done
    puts "Local Calendar Update Complete!"
  end
end

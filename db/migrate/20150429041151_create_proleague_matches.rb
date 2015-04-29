class CreateProleagueMatches < ActiveRecord::Migration
  def change
    create_table :proleague_matches do |t|
      t.string :team1
      t.string :team2
      t.datetime :starttime
      t.datetime :endtime

      t.timestamps
    end
  end
end

class CreateImportAttempts < ActiveRecord::Migration
  def change
    create_table :import_attempts do |t|
      t.boolean :succeeded
      t.integer :match_count
      t.string :api_token
      t.datetime :time

      t.timestamps
    end
  end
end

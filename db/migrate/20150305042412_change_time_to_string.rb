class ChangeTimeToString < ActiveRecord::Migration
  def change
    remove_column :import_attempts, :time
    add_column :import_attempts, :time, :string
  end
end

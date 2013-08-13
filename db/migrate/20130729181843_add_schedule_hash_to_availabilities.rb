class AddScheduleHashToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :schedule_hash, :text
    remove_column :availabilities, :schedule
  end
end

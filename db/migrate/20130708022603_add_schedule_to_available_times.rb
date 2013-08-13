class AddScheduleToAvailableTimes < ActiveRecord::Migration
  def change
    add_column :available_times, :schedule, :text
  end
end

class ChangeWeekdayHourInAvailableTime < ActiveRecord::Migration
  def change
    remove_column :available_times, :weekday
    remove_column :available_times, :hour
    add_column :available_times, :weekday, :string
    add_column :available_times, :hour, :string
  end
end

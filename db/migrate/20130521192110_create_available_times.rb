class CreateAvailableTimes < ActiveRecord::Migration
  def change
    create_table :available_times do |t|
      t.integer :user_id
      t.datetime :time_available
      t.integer :weekday
      t.integer :hour

      t.timestamps
    end
  end
end

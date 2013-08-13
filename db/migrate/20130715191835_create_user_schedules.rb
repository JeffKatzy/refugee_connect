class CreateUserSchedules < ActiveRecord::Migration
  def change
    create_table :user_schedules do |t|
      t.integer :user_id
      t.text :schedule

      t.timestamps
    end
  end
end

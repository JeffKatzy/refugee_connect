class AddScheduledForToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :scheduled_for, :text
  end
end

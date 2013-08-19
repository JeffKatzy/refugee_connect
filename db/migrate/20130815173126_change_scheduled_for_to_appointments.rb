class ChangeScheduledForToAppointments < ActiveRecord::Migration
  def change
  	remove_columns :appointments, :scheduled_for
  	add_column :appointments, :scheduled_for, :datetime
  end
end

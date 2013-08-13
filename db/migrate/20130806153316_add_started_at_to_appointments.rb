class AddStartedAtToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :began_at, :datetime
    add_column :appointments, :ended_at, :datetime
    remove_column :appointments, :occurred_at
  end
end

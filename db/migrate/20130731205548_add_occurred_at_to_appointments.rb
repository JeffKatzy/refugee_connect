class AddOccurredAtToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :occurred_at, :text
  end
end

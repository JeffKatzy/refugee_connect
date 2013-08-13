class RemoveTuteeIdFromAppointments < ActiveRecord::Migration
  def up
  	remove_column :appointments, :tutee_id
  end

  def down
  end
end

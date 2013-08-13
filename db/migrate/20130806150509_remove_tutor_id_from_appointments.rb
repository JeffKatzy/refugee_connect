class RemoveTutorIdFromAppointments < ActiveRecord::Migration
  def up
  	remove_column :appointments, :tutor_id
  end

  def down
  end
end

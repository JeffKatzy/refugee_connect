class AddTutorIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :tutor_id, :integer
    add_column :appointments, :tutee_id, :integer
    remove_column :appointments, :user_id
  end
end

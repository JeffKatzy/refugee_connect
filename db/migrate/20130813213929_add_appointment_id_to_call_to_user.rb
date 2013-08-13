class AddAppointmentIdToCallToUser < ActiveRecord::Migration
  def change
    add_column :call_to_users, :appointment_id, :integer
  end
end

class AddAppointmentIdToTextToUsers < ActiveRecord::Migration
  def change
    add_column :text_to_users, :appointment_id, :integer
  end
end

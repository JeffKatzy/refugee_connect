class AddAppointmentIdToTextFromUsers < ActiveRecord::Migration
  def change
    add_column :text_from_users, :appointment_id, :integer
  end
end

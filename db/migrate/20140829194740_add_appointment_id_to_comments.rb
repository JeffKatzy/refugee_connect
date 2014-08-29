class AddAppointmentIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :appointment_id, :integer
    add_column :comments, :tutee_id, :integer
  end
end

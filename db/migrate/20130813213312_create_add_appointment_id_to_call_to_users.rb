class CreateAddAppointmentIdToCallToUsers < ActiveRecord::Migration
  def change
    create_table :add_appointment_id_to_call_to_users do |t|
      t.integer :appointment_id, :call_to_users

      t.timestamps
    end
  end
end

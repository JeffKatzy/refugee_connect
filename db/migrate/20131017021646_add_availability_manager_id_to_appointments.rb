class AddAvailabilityManagerIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :availability_manager_id, :integer
  end
end

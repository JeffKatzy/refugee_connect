class RemoveAvailabilityManagerIdFromAppointments < ActiveRecord::Migration
  def up
    remove_column :appointments, :availability_manager_id
  end

  def down
    add_column :appointments, :availability_manager_id, :string
  end
end

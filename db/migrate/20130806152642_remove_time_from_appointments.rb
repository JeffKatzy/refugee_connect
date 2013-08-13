class RemoveTimeFromAppointments < ActiveRecord::Migration
  def up
    remove_column :appointments, :time
  end

  def down
    add_column :appointments, :time, :datetime
  end
end

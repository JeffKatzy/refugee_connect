class AddMatchIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :match_id, :integer
  end
end

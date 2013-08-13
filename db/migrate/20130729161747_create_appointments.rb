class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :tutor_id
      t.integer :tutee_id
      t.string :status
      t.datetime :time
      t.integer :start_page
      t.integer :finish_page

      t.timestamps
    end
  end
end

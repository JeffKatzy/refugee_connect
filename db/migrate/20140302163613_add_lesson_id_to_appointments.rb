class AddLessonIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :lesson_id, :integer
  end
end

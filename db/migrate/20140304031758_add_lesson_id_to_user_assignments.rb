class AddLessonIdToUserAssignments < ActiveRecord::Migration
  def change
  	add_column :user_assignments, :user_lesson_id, :integer
  end
end

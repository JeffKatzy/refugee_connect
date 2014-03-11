class RemoveStartPageToUserLessons < ActiveRecord::Migration
  def change
  	remove_column :user_lessons, :start_page
  	remove_column :user_lessons, :last_page
  end
end

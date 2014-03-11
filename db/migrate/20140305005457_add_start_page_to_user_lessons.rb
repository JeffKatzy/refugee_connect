class AddStartPageToUserLessons < ActiveRecord::Migration
  def change
    add_column :user_lessons, :start_page, :integer
  end
end

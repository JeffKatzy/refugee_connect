class AddLastPageToUserLessons < ActiveRecord::Migration
  def change
    add_column :user_lessons, :last_page, :integer
  end
end

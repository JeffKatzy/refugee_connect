class AddStartPageToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :start_page, :integer
    add_column :lessons, :finish_page, :integer
  end
end

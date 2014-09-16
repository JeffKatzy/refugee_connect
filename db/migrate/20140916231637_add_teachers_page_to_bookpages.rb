class AddTeachersPageToBookpages < ActiveRecord::Migration
  def change
    add_column :bookpages, :teachers_page, :boolean
  end
end

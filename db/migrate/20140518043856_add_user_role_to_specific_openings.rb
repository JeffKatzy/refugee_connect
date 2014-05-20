class AddUserRoleToSpecificOpenings < ActiveRecord::Migration
  def change
    add_column :specific_openings, :user_role, :string
  end
end

class AddAssignmentIdToBookpages < ActiveRecord::Migration
  def change
    add_column :bookpages, :assignment_id, :integer
  end
end

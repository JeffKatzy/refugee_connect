class DropBookpagesTable < ActiveRecord::Migration
  def change
  	drop_table :bookpages
  end
end

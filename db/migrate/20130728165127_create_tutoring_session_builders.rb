class CreateTutoringSessionBuilders < ActiveRecord::Migration
  def change
    create_table :tutoring_session_builders do |t|

      t.timestamps
    end
  end
end

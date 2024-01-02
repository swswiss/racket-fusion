class AddTeammateIdToRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :teammate_id, :integer
  end
end

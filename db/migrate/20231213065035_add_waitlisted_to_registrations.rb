class AddWaitlistedToRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :waitlisted, :boolean
  end
end

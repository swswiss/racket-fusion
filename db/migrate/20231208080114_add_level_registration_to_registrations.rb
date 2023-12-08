class AddLevelRegistrationToRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :level_registration, :string
  end
end

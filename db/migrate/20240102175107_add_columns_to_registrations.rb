class AddColumnsToRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :name, :string
    add_column :registrations, :double, :boolean
    add_column :registrations, :pending, :string
  end
end

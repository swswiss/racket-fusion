class AddRegistrationsCountToTournaments < ActiveRecord::Migration[6.1]
  def up
    add_column :tournaments, :registrations_count, :integer, null: false, default: 0

    Tournament.find_each do |tournament|
      tournament.update! registrations_count: tournament.registrations.size
    end
  end

  def down
    remove_column :tournaments, :registrations_count
  end
end

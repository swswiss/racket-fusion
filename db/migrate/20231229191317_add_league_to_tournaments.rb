class AddLeagueToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :league, :boolean
  end
end

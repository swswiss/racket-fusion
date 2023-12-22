class AddStartDatetimeToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :start_datetime, :datetime
  end
end

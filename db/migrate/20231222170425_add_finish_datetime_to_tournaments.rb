class AddFinishDatetimeToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :finish_datetime, :datetime
  end
end

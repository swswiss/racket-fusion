class AddDoubleToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :double, :boolean
  end
end

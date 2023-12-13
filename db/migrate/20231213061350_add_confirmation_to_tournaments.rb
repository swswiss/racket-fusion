class AddConfirmationToTournaments < ActiveRecord::Migration[6.1]
  def change
    add_column :tournaments, :confirmation, :boolean
  end
end

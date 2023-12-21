class AddDateToMatch < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :date, :datetime
  end
end

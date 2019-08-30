class AddClickCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :banner_click_count, :integer, default: 0
    add_column :users, :banner_click_count_special, :integer, default: 0
  end
end

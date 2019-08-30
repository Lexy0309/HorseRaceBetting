class AddGeoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ip_processed, :inet
    add_column :users, :is_aus, :boolean
    add_column :users, :is_nsw, :boolean
  end
end

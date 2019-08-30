class AddAdminFieldToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_admin, :boolean
    add_column :users, :terms_confirmed, :boolean
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :state_manual, :string
  end
end

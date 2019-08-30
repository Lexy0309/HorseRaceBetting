class AddMembershipFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    #add_column :users, :membership_type, :int, default: 0 #1 - mint; 2 - pineapple;
    add_column :users, :membership_up, :datetime
    add_column :users, :disabled_by_admin, :boolean, default: false
    add_column :users, :enabled_by_admin, :boolean, default: false
  end
end

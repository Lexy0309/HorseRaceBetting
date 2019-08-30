class CreateBookmakersUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :bookmakers_users, id: false do |t|
      t.integer :user_id
      t.integer :bookmaker_id
    end
  end
end

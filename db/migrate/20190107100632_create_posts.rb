class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.integer :created_by_id
      t.text :message
      t.string :image
      t.timestamps
    end
  end
end

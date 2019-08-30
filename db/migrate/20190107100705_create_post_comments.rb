class CreatePostComments < ActiveRecord::Migration[5.1]
  def change
    create_table :post_comments do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.text :comment
      t.string :image
      t.timestamps
    end
  end
end

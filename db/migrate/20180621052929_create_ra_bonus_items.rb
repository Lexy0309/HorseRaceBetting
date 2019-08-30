class CreateRaBonusItems < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_bonus_items do |t|
      t.integer :amount
      t.string :category
      t.string :descr
      t.belongs_to :ra_race
    end
  end
end

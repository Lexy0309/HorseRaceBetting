class CreateParticipates < ActiveRecord::Migration[5.1]
  def change
    create_table :participates do |t|
      t.belongs_to :horse
      t.belongs_to :jockey
      t.belongs_to :trainer
      t.belongs_to :race
      t.integer :horse_number
      t.integer :barrier
      t.decimal :weight
      t.integer :age
      t.string :sex
      t.string :position_400
      t.string :position_800
      t.string :margin
      t.string :finished
      t.string :position_in_run
    end
  end
end
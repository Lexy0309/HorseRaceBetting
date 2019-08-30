class CreateRaceClasses < ActiveRecord::Migration[5.1]
  def change
    create_table :race_classes do |t|
      t.string :title
      t.integer :rank
    end
    add_index :race_classes, :title, unique: true
  end
end

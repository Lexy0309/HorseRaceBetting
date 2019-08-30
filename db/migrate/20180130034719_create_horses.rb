class CreateHorses < ActiveRecord::Migration[5.1]
  def change
    create_table :horses do |t|
      t.string :title
      t.integer :age
      t.string :sex
    end
  end
end

class AddSpecialTitleToHorses < ActiveRecord::Migration[5.1]
  def change
    add_column :horses, :special_title, :string
  end
end

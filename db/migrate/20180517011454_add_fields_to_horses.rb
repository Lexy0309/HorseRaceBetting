class AddFieldsToHorses < ActiveRecord::Migration[5.1]
  def change
    add_column :horses, :sire, :string
    add_column :horses, :dam, :string
    add_column :horses, :sire_of_dam, :string
    add_column :horses, :foal_date, :date
  end
end

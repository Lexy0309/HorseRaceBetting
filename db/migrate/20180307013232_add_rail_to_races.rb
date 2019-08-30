class AddRailToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :rail, :string
  end
end

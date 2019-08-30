class AddScoreFieldsToRaces < ActiveRecord::Migration[5.1]
  def change
    add_column :races, :score_fields, :string
  end
end

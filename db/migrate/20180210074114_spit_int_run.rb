class SpitIntRun < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :inrun1, :int
    add_column :participates, :inrun2, :int
    add_column :participates, :inrun3, :int
  end
end

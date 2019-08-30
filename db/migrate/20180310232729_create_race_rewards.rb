class CreateRaceRewards < ActiveRecord::Migration[5.1]
  def change
    create_table :race_rewards do |t|
      t.decimal :win
      t.decimal :place
      t.decimal :quinella2
      t.decimal :quinella3
      t.decimal :trifecta
      t.decimal :first_four
      t.decimal :exacta
      t.decimal :exacta4
      t.belongs_to :race
    end
  end
end
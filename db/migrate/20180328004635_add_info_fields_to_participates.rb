class AddInfoFieldsToParticipates < ActiveRecord::Migration[5.1]
  def change
    10.times do |i|
      add_column :participates, "score#{i+1}info1",:string
      add_column :participates, "score#{i+1}info2",:string
    end
  end
end

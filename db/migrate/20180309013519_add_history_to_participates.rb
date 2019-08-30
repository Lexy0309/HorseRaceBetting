class AddHistoryToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :history, :string
  end
end

class AddFieldsToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :distance_wins, :string
    add_column :participates, :previous_inrun, :string
  end
end

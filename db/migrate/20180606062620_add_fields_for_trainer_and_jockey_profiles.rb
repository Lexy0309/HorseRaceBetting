class AddFieldsForTrainerAndJockeyProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :trainers, :total, :integer
    add_column :trainers, :win, :integer
    add_column :trainers, :place, :integer
    add_column :trainers, :track_id, :integer
    add_column :trainers, :jockey_id, :integer
    add_column :trainers, :distance, :integer

    add_column :jockeys, :total, :integer
    add_column :jockeys, :win, :integer
    add_column :jockeys, :place, :integer
    add_column :jockeys, :track_id, :integer
    add_column :jockeys, :trainer_id, :integer
    add_column :jockeys, :distance, :integer
  end
end

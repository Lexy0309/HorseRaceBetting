class CreateTrackDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :track_details do |t|
      t.belongs_to :track
      t.belongs_to :state
    end
  end
end

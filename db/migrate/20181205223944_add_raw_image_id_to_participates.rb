class AddRawImageIdToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :raw_image_id, :integer
  end
end

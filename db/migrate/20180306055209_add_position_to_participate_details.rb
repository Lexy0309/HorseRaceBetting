class AddPositionToParticipateDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :participate_details, :position, :integer
  end
end

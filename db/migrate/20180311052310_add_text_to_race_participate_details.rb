class AddTextToRaceParticipateDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :participate_details, :running_double_text, :string
    add_column :participate_details, :daily_double_text, :string
    add_column :participate_details, :quaddie_text, :string
    add_column :participate_details, :early_quaddie_text, :string
  end
end

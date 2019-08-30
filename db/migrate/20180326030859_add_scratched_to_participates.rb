class AddScratchedToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :scratched, :int
  end
end

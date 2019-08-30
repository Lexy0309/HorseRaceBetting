class AddSpellToParticipates < ActiveRecord::Migration[5.1]
  def change
    add_column :participates, :spell, :integer
  end
end

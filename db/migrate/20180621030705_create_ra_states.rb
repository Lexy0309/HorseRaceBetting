class CreateRaStates < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_states do |t|
      t.string :title
    end
    add_index :ra_states, :title
  end
end

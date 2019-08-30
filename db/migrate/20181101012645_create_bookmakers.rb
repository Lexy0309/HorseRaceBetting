class CreateBookmakers < ActiveRecord::Migration[5.1]
  def change
    create_table :bookmakers do |t|
      t.string :title
    end
  end
end

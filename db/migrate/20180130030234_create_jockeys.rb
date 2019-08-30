class CreateJockeys < ActiveRecord::Migration[5.1]
  def change
    create_table :jockeys do |t|
      t.string :title
    end
  end
end

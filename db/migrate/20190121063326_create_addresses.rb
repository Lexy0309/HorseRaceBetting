class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.belongs_to :user
      t.string :type
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zipcode
      t.timestamps
    end
  end
end

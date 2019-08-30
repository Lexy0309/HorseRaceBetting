class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :payment_gateway_plan_identifier
      t.string :name
      t.monetize :price
      t.integer :interval
      t.integer :interval_count
      t.integer :status
      t.text :description

      t.timestamps
    end
  end
end

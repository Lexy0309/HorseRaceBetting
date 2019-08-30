class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.string :payment_gateway
      t.string :payment_gateway_subscription_id

      t.timestamps
    end
  end
end

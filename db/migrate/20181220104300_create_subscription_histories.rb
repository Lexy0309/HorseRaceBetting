class CreateSubscriptionHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_histories do |t|
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true
      t.integer :status
      t.string :payment_gateway_subscription_id
      t.string :message
      t.integer :subscribed_by
      t.timestamps
    end
  end
end

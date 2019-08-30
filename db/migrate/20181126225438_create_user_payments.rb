class CreateUserPayments < ActiveRecord::Migration[5.1]
  def change
    create_table :user_payments do |t|
      t.text :notification_params
      t.string :status
      t.string :transaction_id
      t.datetime :purchased_at
      t.belongs_to :user
    end
  end
end

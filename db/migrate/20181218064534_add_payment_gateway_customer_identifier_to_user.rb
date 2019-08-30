class AddPaymentGatewayCustomerIdentifierToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :payment_gateway_customer_identifier, :string
  end
end

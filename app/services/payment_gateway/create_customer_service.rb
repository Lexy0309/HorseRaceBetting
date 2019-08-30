class PaymentGateway::CreateCustomerService < PaymentGateway::Service

  attr_accessor :user, :source

  def initialize(user:, source:)
    @user = user
    @source = source
  end

  def run
    begin
      User.transaction do
        # if user.payment_gateway_customer_identifier.present?
        #   client.lookup_customer(identifier: user.payment_gateway_customer_identifier)
        # else
          client.create_customer!(email: user.email, source: source).tap do |customer|
            user.update!(payment_gateway_customer_identifier: customer.id)
          end
        # end
      end
    rescue => e
      raise PaymentGateway::ServiceError.new("There was an error while creating the customer : ", e.message)
    end
  end
end

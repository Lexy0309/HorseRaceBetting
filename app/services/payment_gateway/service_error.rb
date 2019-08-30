class PaymentGateway::ServiceError < StandardError
  def initialize(message)
    super(message)
  end
end

class PaymentGateway::StripeClientError < PaymentGateway::ServiceError
  def initialize(message)
    super(message)
  end
end

class PaymentGateway::ClientError < PaymentGateway::ServiceError
  def initialize(message)
    super(message)
  end
end

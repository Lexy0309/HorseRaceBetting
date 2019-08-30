class PaymentGateway::Client
  attr_accessor :external_client

  def initialize(external_client: PaymentGateway::StripeClient.new)
    @external_client = external_client
  end

  def method_missing(*args, &block)
    begin
      external_client.send(*args, &block)
    rescue => e
      raise PaymentGateway::ClientError.new(e.message)
    end
  end
end

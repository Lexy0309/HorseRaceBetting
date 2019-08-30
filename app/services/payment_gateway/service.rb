class PaymentGateway::Service
  protected
    def client
      @client ||= PaymentGateway::Client.new
    end
end
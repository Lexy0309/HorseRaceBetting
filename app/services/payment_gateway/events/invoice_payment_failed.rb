class PaymentGateway::Events::InvoicePaymentFailed
  def call(payment_gateway_event)
    create_event(verified_payment_gateway_event(payment_gateway_event))
  end

  private

  def create_event(event)
    Event.create!(JSON.parse(event.to_json))
  end

  def get_payment_gateway_event(event)
    get_plan_service = PaymentGateway::GetPlanService.new(event.id)
    get_plan_service.run
  end
end
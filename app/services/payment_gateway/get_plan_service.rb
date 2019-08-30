class PaymentGateway::GetPlanService < PaymentGateway::Service
  attr_accessor :plan

  def initialize(plan: )
    @plan = plan
  end

  def run
    begin
   	  get_client_event
    rescue  => e
      p e.message
    end
  end

  private

  def get_client_event
    client.lookup_plan(identifier: plan.payment_gateway_plan_identifier)
  end
end

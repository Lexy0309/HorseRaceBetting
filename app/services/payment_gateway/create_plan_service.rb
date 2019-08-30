class  PaymentGateway::CreatePlanService < PaymentGateway::Service
  EXCEPTION_MESSAGE = "There was an error while creating the plan"
  attr_accessor :payment_gateway_plan_identifier, :name, :price_cents, :interval, :interval_count, :description

  def initialize(payment_gateway_plan_identifier:, name:, price_cents:, interval:, interval_count:, description:)
    @payment_gateway_plan_identifier = payment_gateway_plan_identifier
    @name = name
    @price_cents = price_cents
    @interval = interval
    @interval_count = interval_count
    @description = description
  end

  def run
    begin
      Plan.transaction do
        create_client_plan
        create_plan
      end
    rescue => e
      p e.message
    end
  end

  private
  def create_client_plan
    client.create_plan!(
      name,
      id: payment_gateway_plan_identifier,
      amount: price_cents,
      currency: "usd",
      interval: interval,
      interval_count: interval_count
    )
  end

  private
  def create_plan
    Plan.create!(
      payment_gateway_plan_identifier: payment_gateway_plan_identifier,
      name: name,
      price_cents: price_cents,
      interval: interval,
      interval_count: interval_count,
      status: :active,
      description: description)
  end
end

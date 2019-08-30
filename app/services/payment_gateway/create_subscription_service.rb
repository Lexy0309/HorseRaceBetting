class PaymentGateway::CreateSubscriptionService < PaymentGateway::Service

  attr_accessor :user, :plan, :token, :subscription, :success

  def initialize(user:, plan:, token:)
    @user = user
    @plan = plan
    @token = token
    @successs = false
  end

  def run
    begin
      Subscription.transaction do
        subscription = create_client_subscription
        self.subscription = create_subscription(subscription)
        self.success = true
      end
    rescue => e
      raise PaymentGateway::ServiceError.new("There was an error while creating the subscription : ", e.message)
    end
  end

  private
    def create_client_subscription
      client.create_subscription!(
        customer: payment_gateway_customer,
        plan: paymeny_gateway_plan)
    end

  private
    def create_subscription(subscription)
      SubscriptionHistory.create(user: user, plan: plan, subscribed_by: user.id, status: :active, payment_gateway_subscription_id: subscription.id, message: 'create subscription by user with stripe')
      Subscription.create!(user: user,
        plan: plan,
        start_date: Time.zone.now.to_date,
        # end_date: plan.end_date_from,
        status: :active,
        payment_gateway_subscription_id: subscription.id)
    end

  private
    def payment_gateway_customer
      create_customer_service = PaymentGateway::CreateCustomerService.new(
        user: user,
        source: token)
      create_customer_service.run
    end

  private
    def paymeny_gateway_plan
      get_plan_service = PaymentGateway::GetPlanService.new(
        plan: plan)
      get_plan_service.run
    end
end

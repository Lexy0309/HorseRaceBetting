class PaymentGateway::CancelSubscriptionService < PaymentGateway::Service
  ERROR_MESSAGE = "There was an error while canceling the subscription"
  attr_accessor :user, :plan, :subscription

  def initialize(user:, plan:, subscription:)
    @user = user
    @plan = plan
    @subscription = subscription
  end

  def run
    begin
      Subscription.transaction do
        cancel_client_subscription if subscription.payment_gateway_subscription_id
        cancel_subscription
      end
    rescue => e
      p e.message
    end
  end

  private

  def cancel_client_subscription
    client.cancel_subscription!(identifier: subscription.payment_gateway_subscription_id)
  end

  def cancel_subscription
    SubscriptionHistory.create(user: user, plan: plan, subscribed_by: user.id, status: :canceled, payment_gateway_subscription_id: subscription.payment_gateway_subscription_id, message: 'cancel subscription by user with stripe')
    subscription.destroy
  end
end

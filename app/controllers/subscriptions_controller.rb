class SubscriptionsController < ApplicationController

  rescue_from PaymentGateway::ServiceError do |e|
    redirect_to plans_path, alert: e.message
  end

  before_action :authenticate_user!
  before_action :load_plan
  before_action :find_subscription, only: [:show, :cancel_subscription]

  def new
    @subscription = Subscription.new
  end

  def show
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def create
    service = PaymentGateway::CreateSubscriptionService.new(
      user: current_user,
      plan: @plan,
      token: params[:payment_gateway_token])
    if service.run && service.success
      current_user.subscriptions.where.not(id: service.subscription.id).each{ |s| cancel_plan_subscription(s.plan, s)}
      redirect_to plan_subscription_path(@plan, service.subscription),
      notice: "Your subscription has been created."
    else
      render :new
    end
  end

  def cancel_subscription
    if @subscription.payment_gateway_subscription_id == 'Free Trial'
      SubscriptionHistory.create(user: current_user, plan_id: @plan.id, subscribed_by: current_user.id, status: :canceled, payment_gateway_subscription_id: 'Free Trial', message: 'cancel subscription by user with stripe')
      @subscription.destroy
    else
      cancel_plan_subscription(@plan, @subscription)
    end
    redirect_to plans_path, notice: "Subscription has been canceled successfully."
  end

  def store_billing_detail
    current_user.mobile_number = params[:mobile_number]
    current_user.build_billing_address.assign_attributes(address1: params[:billing_address1], address2: params[:billing_address2], city: params[:billing_city], state: params[:billing_state], zipcode: params[:billing_zipcode])
    current_user.build_delivery_address.assign_attributes(address1: params[:delivery_address1], address2: params[:delivery_address2], city: params[:delivery_city], state: params[:delivery_state], zipcode: params[:delivery_zipcode])
    current_user.save
    redirect_to new_plan_subscription_path(@plan)
  end

  def free_trial
    current_user.subscriptions.each{ |s| cancel_plan_subscription(s.plan, s)}
    current_user.subscriptions.create(plan_id: @plan.id, start_date: Time.zone.now.to_date, status: :active, payment_gateway_subscription_id: 'Free Trial')
    SubscriptionHistory.create(user: current_user, plan: @plan, subscribed_by: current_user.id, status: :active, payment_gateway_subscription_id: 'Free Trial', message: 'create subscription by user with stripe')
    redirect_to plans_path, notice: "Free trial subscription has been created successfully, you can access Magic ball."
  end

  private

  def load_plan
    @plan = Plan.find_by(id: params[:plan_id])
    redirect_to plans_path, notice: "Plan Id is missing" unless @plan.present?
  end

  def find_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def cancel_plan_subscription(plan, subscription)
    service = PaymentGateway::CancelSubscriptionService.new(user: current_user, plan: plan, subscription: subscription)
    service.run
    subscription.destroy
  end
end

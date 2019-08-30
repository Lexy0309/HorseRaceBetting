class UserController < ApplicationController
  require 'paypal_lib'

  protect_from_forgery except: [:hook]
  before_action :access_deny_in_if_not_an_admin, except: [:hook,:process_payment]
  before_action :access_deny_in_if_not_a_user, only: [:process_payment]

  def index
    @users = User.includes(:bookmakers).where(terms_confirmed:true)
  end

  def horse_race_object_click
    @user = User.find(params[:id])
    if params[:special].to_i.zero?
      @user.banner_click_count += 1
    else
      @user.banner_click_count_special += 1
    end
    @user.save
    render plain: 'ok'
  end

  def disable_by_admin
    @user = User.find(params[:id])
    @user.disabled_by_admin = params[:reverse].to_i.zero?
    @user.save
    redirect_to(user_index_path) and return
  end

  def enable_by_admin
    @user = User.find(params[:id])
    @user.enabled_by_admin = params[:reverse].to_i.zero?
    @user.save
    redirect_to(user_index_path) and return
  end

  def continue_membership_by_admin
    @user = User.find(params[:id])
    @user.continue_membership
    redirect_to(user_index_path) and return
  end

  def clear_membership_by_admin
    @user = User.find(params[:id])
    @user.clear_membership
    redirect_to(user_index_path) and return
  end

  def process_payment
    @user = User.find(params[:id])
    @user_payment = UserPayment.create(user:@user)
    redirect_to @user_payment.paypal_url(edit_user_registration_path)
  end

  def hook
    params.permit!
    status = params[:payment_status]
    if status == 'Completed' && PayPalLib.verified?(params.to_hash)
      @user_payment = UserPayment.find(params[:invoice])
      @user_payment.update_attributes notification_params: params.to_hash, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render plain: 'ok'
  end

  def free_subscription_plan
    @user = User.find_by_email(params[:user_email])
    SubscriptionHistory.create(user: @user, plan_id: params[:plan_id], subscribed_by: current_user.id, status: :active, message: 'create subscription by admin')
    Subscription.create!(user: @user, plan_id: params[:plan_id], start_date: Time.zone.now.to_date, status: :active)
    redirect_to(user_index_path, notice: 'Plan subscription created successfully')
  end
end

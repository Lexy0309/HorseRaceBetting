class User < ApplicationRecord
  has_and_belongs_to_many :bookmakers
  has_many :post_comments
  has_many :user_payments
  has_many :subscriptions
  has_many :plans, :through => :subscriptions
  has_one :billing_address, class_name: BillingAddress, :dependent => :destroy
  has_one :delivery_address, class_name: DeliveryAddress, :dependent => :destroy

  require 'unirest'
  STATES = ['Non-AUS','QLD','NT','ACT','VIC','WA','TAS','NSW']

  validates :first_name, length: { minimum: 3 }, on: :update
  validates :last_name, length: { minimum: 3 }, on: :update
  validates :state_manual, inclusion: User::STATES, on: :update

  # Include default devise modules. Others available are:
  #:recoverable, :rememberable, :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :validatable, :omniauthable, :registerable, :timeoutable, omniauth_providers: [:facebook]

  MINT = 'Mint'
  PINEAPPLE = 'Pineapple'

  def is_admin?
    is_admin
  end

  def show_membership
    if disabled_by_admin
      'Disabled by admin'
    elsif enabled_by_admin
      'Infinity by admin'
    elsif !membership_up.blank? && membership_up>Time.now
      "#{MINT} up #{membership_up.strftime('%d/%m/%Y')}"
    else
      'You are currently a free service member'
    end
  end

  def full_name
    first_name.to_s + " " + last_name.to_s
  end

  def has_first_tier?
    plans.where(payment_gateway_plan_identifier: 'pineapples_tier_1').count > 0
  end

  def has_second_tier?
    plans.where(payment_gateway_plan_identifier: 'gorillas_tier_2').count > 0
  end

  def has_third_tier?
    plans.where(payment_gateway_plan_identifier: 'magic_eightball_tier_3').each{|p| get_subscription(p.id)}
    return plans.where(payment_gateway_plan_identifier: 'magic_eightball_tier_3').count > 0
  end

  def get_subscription(plan_id)
    subscription = subscriptions.where(plan_id: plan_id).first
    if subscription.present?
      if subscription.payment_gateway_subscription_id == 'Free Trial'
        if Date.today > Date.parse("25/01/2019")
          SubscriptionHistory.create(user: self, plan_id: plan_id, subscribed_by: self.id, status: :canceled, payment_gateway_subscription_id: 'Free Trial', message: 'cancel subscription by user with stripe')
          subscription.destroy
          return nil
        else
          return subscription
        end
      else
        lookup_subscription = Stripe::Subscription.retrieve(subscription.payment_gateway_subscription_id)
        if lookup_subscription.status == "active"
          return subscription
        else
          SubscriptionHistory.create(user: self, plan_id: plan_id, subscribed_by: self.id, status: :canceled, payment_gateway_subscription_id: subscription.payment_gateway_subscription_id, message: 'cancel subscription by user with stripe')
          subscription.destroy
          return nil
        end
      end
    else
      return nil
    end
  end

  def continue_membership
    self.membership_up = ((membership_up.blank? || membership_up < Time.now) ? Time.now : membership_up) + 86400*7
    self.save
  end

  def clear_membership
    self.membership_up = nil
    self.save
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.process_ip_address(ip)
    result = {aus: false, nsw: false}
    begin
      link = "https://api.ipstack.com/#{ip}?access_key=c6d3ce93c07d4888f0c2c45456d0a7b5"
      request = Unirest.get(link)
      data = request.body
      if data.include?('country_name') && data['country_name']=='Australia'
        result[:aus] = true
      end
      if data.include?('region_code') && data['region_code']=='NSW'
        result[:nsw] = true
      end
      if data.include?('region_code') && %w[QLD NT ACT VIC WA TAS NSW].include?(data['region_code'])
        result[:state] = data['region_code']
      end
    rescue
      Rails.logger.error("IP stack error in #{ip}")
    end
    result
  end

  def process_ip_address
    unless current_sign_in_ip==ip_processed
      result = User.process_ip_address(current_sign_in_ip)
      self.is_aus = result[:aus]
      self.is_nsw = result[:nsw]
      self.state = result[:state]
      self.ip_processed = current_sign_in_ip
      self.save
    end
  end
end

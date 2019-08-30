class PaymentGateway::StripeClient

  def lookup_customer(identifier: )
    handle_client_error do
      @lookup_customer ||= Stripe::Customer.retrieve(identifier)
    end
  end

  def lookup_plan(identifier: )
    handle_client_error do
      @lookup_plan ||= Stripe::Plan.retrieve(identifier)
    end
  end

  def lookup_event(identifier: )
    handle_client_error do
      @lookup_event ||= Stripe::Event.retrieve(identifier)
    end
  end

  def create_customer!(options={})
    handle_client_error do
      Stripe::Customer.create(email: options[:email], source: options[:source])
    end
  end

  def create_plan!(product_name, options={})
    handle_client_error do
      Stripe::Plan.create(
        id: options[:id],
        amount: options[:amount],
        currency: options[:currency] || "usd",
        interval: options[:interval] || "week",
        interval_count: options[:interval_count] || 1,
        product: {
          name: product_name
        }
      )
    end
  end

  def create_subscription!(customer: , plan: )
    handle_client_error do
      Stripe::Subscription.create(
        :customer => customer.id,
        :cancel_at_period_end => plan.id == "magic_eightball_tier_3", #Will not be auto-renewed and the user will need to subscribe again
        :items => [
          {
            :plan => plan.id
          }
        ]
      )
    end
  end

  def cancel_subscription!(identifier: )
    handle_client_error do
      @lookup_subscription ||= Stripe::Subscription.retrieve(identifier)
      @lookup_subscription.delete
    end
  end

  private def handle_client_error(message=nil, &block)
    begin
      yield
    rescue Stripe::StripeError => e
      raise PaymentGateway::StripeClientError.new(e.message)
    end
  end
end

require "stripe"
Stripe.api_key             = 'sk_live_yRZ0CSl6pMSvER7K2ICzrkXe'
StripeEvent.signing_secret = 'pk_live_AecqywrL03v7UkiYSiWxEXlz'

StripeEvent.configure do |events|
  events.subscribe(
    'invoice.payment_failed',
    PaymentGateway::Events::InvoicePaymentFailed.new)
end

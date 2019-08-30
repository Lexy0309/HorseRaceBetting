class PayPalLib
  def self.verified?(raw)
    Rails.logger.info("verification PayPal #{raw}")
    r = Unirest.post('https://ipnpb.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate',parameters:raw)
    r.body=='VERIFIED'
  end
end
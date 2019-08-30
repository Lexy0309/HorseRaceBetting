class UserPayment < ApplicationRecord
  belongs_to :user

  def paypal_url(return_path)
    values = {
        business: 'seller@betbuilder.com.au',
        cmd: '_xclick-subscriptions',
        upload: 1,
        return: "https://betbuilder.com.au#{return_path}",
        invoice: id,
        currency_code: 'AUD',
        a3: 5,
        p3: 1,
        src: 1,
        srt: 52,
        t3: 'D',
        item_name: 'test item',
        notify_url: 'https://betbuilder.com.au/user/hook'
    }
    "https://www.sandbox.paypal.com/cgi-bin/webscr?#{values.to_query}"
  end
end
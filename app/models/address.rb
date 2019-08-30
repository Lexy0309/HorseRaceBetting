class Address < ApplicationRecord
  belongs_to :user

  validates :address1, :city, :state, :zipcode, :presence => true

  def full_address
    address = address1 + "<br/>"
    address += address2 + "<br/>" if address2.present?
    address += city + " " + zipcode + " " + state
    return address.html_safe
  end
end

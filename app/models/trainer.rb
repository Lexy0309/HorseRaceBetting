class Trainer < ApplicationRecord
  has_many :participates
  belongs_to :track
  belongs_to :jockey

  def winrate
    "#{total.to_i.zero? ? 0 : (win.to_i/total.to_f*100).to_i}%"
  end

  def placerate
    "#{total.to_i.zero? ? 0 : (place.to_i/total.to_f*100).to_i}%"
  end
end

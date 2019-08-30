class BetRace < ApplicationRecord
  belongs_to :bet
  belongs_to :race
  has_many :bet_horses
end

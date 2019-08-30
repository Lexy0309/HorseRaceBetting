class MagicBallFrame < ApplicationRecord
  belongs_to :winner, class_name: 'Race', foreign_key: 'race_id', optional: true
  has_and_belongs_to_many :races
end

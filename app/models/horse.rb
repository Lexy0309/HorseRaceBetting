class Horse < ApplicationRecord
  has_many :participates
  has_many :horse_positions
end

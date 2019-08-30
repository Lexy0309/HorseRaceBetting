class RaTrackRecord < ApplicationRecord
  has_many :ra_races
  belongs_to :ra_track
end

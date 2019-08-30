class RaTrack < ApplicationRecord
  belongs_to :ra_state
  has_many :ra_meetings
  has_many :ra_track_days
  has_many :ra_track_records
end

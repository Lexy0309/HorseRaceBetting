class RaMeeting < ApplicationRecord
  belongs_to :ra_track
  has_one :ra_track_day
end

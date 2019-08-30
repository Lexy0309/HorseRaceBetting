class RaRace < ApplicationRecord
  belongs_to :ra_meeting
  belongs_to :ra_track_day
  belongs_to :ra_track
  belongs_to :ra_track_record
  has_many :ra_race_conditions
  has_many :ra_prize_moneys
  has_many :ra_bonus_items
end

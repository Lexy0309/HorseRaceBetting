class RacePool < ApplicationRecord
  belongs_to :race
  BET_TITLES = %w[win place quinella exacta duet trifecta first_four running_double daily_double early_quaddie quaddie]

  def self.capitalize_special(bet_title)
    result = ''
    upcase_flag = false
    bet_title.split('').each_with_index do |letter,index|
      if index==0
        result << letter.upcase
      elsif letter=='_'
        upcase_flag = true
      elsif upcase_flag
        upcase_flag = false
        result << ' '
        result << letter.upcase
      else
        result << letter
      end
    end
    result
  end

end

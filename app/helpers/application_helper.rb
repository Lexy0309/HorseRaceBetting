module ApplicationHelper

  def current_zone
    utc_offset = 11
    ActiveSupport::TimeZone[utc_offset].name
  end

  def get_today_raw(add_days=0)
    (DateTime.now + add_days).in_time_zone(current_zone)
  end

  def get_today(add_days=0)
    get_today_raw(add_days).strftime('%Y-%m-%d')
  end

  def get_today_daily
    Rails.env=='development' ? '2019-01-25' : get_today()
  end

  def get_today_dmy(add_days=0)
    get_today_raw(add_days).strftime('%d-%m-%Y')
  end

  def average(value,total,round=2)
    total.zero? ? total : (value / total.to_f).round(round)
  end

  def initial_date
    DateTime.new(2018,2,1).in_time_zone(current_zone)
  end

  def check_date(raw)
    begin
      date = DateTime.strptime(raw,'%Y-%m-%d').in_time_zone(current_zone).to_date
    rescue
      return false
    end
    initial_date.to_date <= date && get_today_raw(1).to_date >= date
  end

  def display_dmy(yyyy_mm_dd)
    divider = yyyy_mm_dd[4]
    y,m,d = yyyy_mm_dd.split(divider)
    "#{d}#{divider}#{m}#{divider}#{y}"
  end

  def dollarize(value)
    if value.to_s.start_with?('-')
      "-$#{value.to_s[1,value.to_s.size]}"
    else
      "$#{value}"
    end
  end

  def weekday_titles
    %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end

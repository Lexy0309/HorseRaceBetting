class RaceClass < ApplicationRecord

  def self.get_external
    sql = 'select distinct race_class from race_tabs where race_class not in (select title from race_classes) order by 1'
    ActiveRecord::Base.connection.execute(sql).values.map{|v| v[0]}
  end
end

class RaceConditionDetail < ApplicationRecord
  def self.get_external
    sql = "select distinct condition from race_tabs where condition not in (select title from race_condition_details) and coalesce(condition,'')<>'' order by 1"
    ActiveRecord::Base.connection.execute(sql).values.map{|v| v[0]}
  end
end

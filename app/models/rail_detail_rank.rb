class RailDetailRank < ApplicationRecord
  def self.get_external
    sql = "select distinct rail from races where rail not in (select title from rail_detail_ranks) and coalesce(rail,'')<>''"
    ActiveRecord::Base.connection.execute(sql).values.map{|v| v[0]}
  end
end

class ClassSectionalController < ApplicationController
  before_action :access_deny_in_if_not_an_admin

  def index
    sql = 'select t.race_class,count(*),min(sectional_time),max(sectional_time),round(avg(sectional_time),2)'
    sql << ' from races r'
    sql << " join participates p on r.id=p.race_id and p.finished='1'"
    sql << ' join race_tabs t on t.race_id=r.id'
    sql << " where start_date>'2018-02-01' group by t.race_class order by t.race_class"
    @result =  ActiveRecord::Base.connection.execute(sql).values
  end
end

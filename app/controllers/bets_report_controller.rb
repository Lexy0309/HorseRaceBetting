class BetsReportController < ApplicationController
  before_action :access_deny_in_if_not_an_admin


  def index
    sql = 'select category,count(*),sum(case when reward=0 then 0 else 1 end),round(sum(amount),2),round(sum(reward),2) from bets group by category order by category'
    @result =  ActiveRecord::Base.connection.execute(sql).values
    sql = "select id,start_date,amount,reward,price,race_id,string_agg(race_number||': '||horses,';  '),to_char( start_date, 'dd-mm-yyyy')
    from (
      select id,start_date,amount,reward,price,race_id,race_number,string_agg(cast(horse_number as varchar),'-')as horses
      from (
        select b.id,b.start_date,b.amount,b.reward,b.price,bx.race_id,race_number,bh.horse_number
        from bets b
        join bet_races br on br.bet_id=b.id
        join races r on br.race_id=r.id
        join bet_horses bh on bh.bet_race_id=br.id
        join (
          select bet_id,race_id
          from (
            select bet_id,br.race_id,rank() over (partition by bet_id order by r.race_number desc)as x
            from bet_races br
            join bets b on b.id=br.bet_id and b.category=3 and b.reward>0
            join races r on r.id=br.race_id
          )z where x=1
        )bx on bx.bet_id=b.id
        where b.category=2 and reward>0
      )x group by id,start_date,amount,reward,price,race_id,race_number
    )x group by id,start_date,amount,reward,price,race_id"
    @quaddie =  ActiveRecord::Base.connection.execute(sql).values
    @calendar_min,@calendar_max = ActiveRecord::Base.connection.execute('select min(start_date),max(start_date) from bets').values[0]
  end

  def show
    @date = params[:id]
    @data = Bet.where(start_date:@date)
    unless @data.blank?
      next_date_raw = ActiveRecord::Base.connection.execute("select start_date from bets where start_date>'#{@date}' order by start_date limit 1;").values
      @next_date = next_date_raw.blank? ? '' : next_date_raw[0][0]
      prev_date_raw = ActiveRecord::Base.connection.execute("select start_date from bets where start_date<'#{@date}' order by start_date desc limit 1;").values
      @prev_date = prev_date_raw.blank? ? '' : prev_date_raw[0][0]
      sql = "select category,count(*),sum(case when reward=0 then 0 else 1 end),round(sum(amount),2),round(sum(reward),2) from bets where start_date='#{@date}' group by category order by category"
      @total_data = ActiveRecord::Base.connection.execute(sql).values
      @quinella = Bet.get_category_data(1,@date)
      @quaddie = Bet.get_category_data(2,@date)
      #@exacta4 = Bet.get_category_data(3,@date)
      @exacta3 = Bet.get_category_data(4,@date)
      @trifecta = Bet.get_category_data(5,@date)
      @firstfour = Bet.get_category_data(6,@date)
      #@trifecta1 = Bet.get_category_data(7,@date)
      #@trifecta2 = Bet.get_category_data(8,@date)
      #@trifecta3 = Bet.get_category_data(9,@date)
      @trifecta4 = Bet.get_category_data(10,@date)
      @trifecta5 = Bet.get_category_data(11,@date)
      @win1 = Bet.get_category_data(12,@date)
      @win2 = Bet.get_category_data(13,@date)
      @win3 = Bet.get_category_data(14,@date)
      @win4 = Bet.get_category_data(15,@date)
      @win5 = Bet.get_category_data(16,@date)
      @win6 = Bet.get_category_data(17,@date)
      @win7 = Bet.get_category_data(18,@date)
      @win_special1 = Bet.get_category_data(19,@date)
      @win_special2 = Bet.get_category_data(20,@date)
      @win_special3 = Bet.get_category_data(21,@date)
      @win_special4 = Bet.get_category_data(22,@date)
      @win_special5 = Bet.get_category_data(23,@date)
      @win8 = Bet.get_category_data(28,@date)
      @win9 = Bet.get_category_data(29,@date)
      @win10 = Bet.get_category_data(30,@date)
      @win11 = Bet.get_category_data(31,@date)
      @firstfour2 = Bet.get_category_data(27,@date)
      @trifecta6 = Bet.get_category_data(24,@date)
      @trifecta7 = Bet.get_category_data(25,@date)
      @trifecta8 = Bet.get_category_data(26,@date)
      @special_double = Bet.get_category_data(33,@date)
    end
  end

  def graph

  end

  def api
    allowed_params = params.permit(:type,:categories)
    type = %w[month day week].include?(allowed_params[:type]) ? allowed_params[:type] : 'day'
    categories = allowed_params[:categories].to_s.split(',').map(&:to_i).select{|category| Bet::CATEGORY_DATA.include? category}
    categories = categories.blank? ? Bet::CATEGORY_DATA.keys : categories
    if type=='day'
      sql_part = 'extract(isodow from start_date)-1'
    elsif type=='month'
      sql_part = "date_part('month',start_date)-1"
    elsif type=='week'
      sql_part = "case when date_part('day',start_date) <=7 then 1 when date_part('day',start_date) <=14 then 2 when date_part('day',start_date) <=21 then 3 when date_part('day',start_date) <=28 then 4 else 5 end"
    end
    sql = "select #{sql_part},category,case when sum(amount)=0 then 0 else round(100*sum(reward)/sum(amount)) end
from bets
where category in (#{categories.join(',')})
group by #{sql_part},category"
    values = ActiveRecord::Base.connection.execute(sql).values
    result_raw = {}
    result = []
    values.each do |row|
      key,category,value = row
      key = key.to_i
      value = value.to_i
      if result_raw.include?(key)
        result_raw[key][category] = value
      else
        result_raw[key] = {category=>value}
      end
    end
    result_raw.keys.sort.each do |key|
      value = result_raw[key]
      elem = {}
      if type=='day'
        elem['title'] = weekday_titles[key]
      elsif type=='month'
        elem['title'] = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec][key]
      elsif type=='week'
        elem['title'] = "Week #{key}"
      end
      categories.each do |category|
        elem[category] = value[category].to_i
      end
      result << elem
    end
    render json: {fields: categories.map{|category| {title: Bet::CATEGORY_DATA[category],special: category.to_s}},data: result}.as_json
  end

  def category
    @id = params[:id].to_i
    unless Bet::CATEGORY_DATA.include?(@id)
      redirect_to(bets_report_index_path) && return
    end
    @data = Bet.where(category:@id).includes(bet_races: {race: :track})
  end

  def by_week_special
    allowed_params = params.permit(:start_date,:weekdays,:categories)
    start_date = allowed_params[:start_date].to_s
    weekdays_default = [1,2,3,4,5,6,7]
    weekdays = allowed_params[:weekdays].to_s
    weekdays = weekdays.split(',').uniq.map(&:to_i).select{|wd| (1..7).include?(wd)}.sort
    weekdays = weekdays.blank? ? weekdays_default : weekdays
    categories_default = [1,2,3,4,5,6,7]
    categories = allowed_params[:categories].to_s
    categories = categories.split(',').uniq.map(&:to_i).select{|c| Bet::CATEGORY_DATA.include?(c)}.sort
    categories = categories.blank? ? categories_default : categories
    begin
      y,m,d = allowed_params[:start_date].split('-').map(&:to_i)
      start_date = [[Time.new(2017,1,1),Time.new(y,m,d)].max,Time.now].min.strftime('%Y-%m-%d')
    rescue
      start_date = '2017-01-01'
    end
    sql = "select cast('#{start_date}'as date)+(ceil((start_date-cast('#{start_date}'as date)+1)/7.0)-1)*7*interval ' 1day'
    ,ceil((start_date-cast('#{start_date}'as date)+1)/7.0),sum(amount),sum(reward),sum(reward-amount)
    from bets
    where start_date>='#{start_date}' and case extract(dow from start_date) when 0 then 7 else extract(dow from start_date) end in (#{weekdays.join(',')})
    and category in (#{categories.join(',')})
    group by ceil((start_date-cast('#{start_date}'as date)+1)/7.0)
    order by 1"
    weeks = ActiveRecord::Base.connection.execute(sql).values
    render(json: {data:weeks,graph_data:weeks.map{|row| {title:row[1],amount:row[2].to_f,reward:row[3].to_f}}})
  end

  def by_week

  end
end

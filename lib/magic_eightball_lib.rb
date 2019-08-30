class MagicEightball

  def self.get_frame_duration(track_count)
    if track_count>=5
      minutes = 20
    elsif track_count==4
      minutes = 30
    else
      minutes = 45
    end
    minutes * 60
  end

  def self.get_frame_borders(date,duration,timestamp)
    sql = "select min(race_dt),max(race_dt) from races where start_date='#{date}'"
    min_dt,max_dt = ActiveRecord::Base.connection.execute(sql).values[0]
    empty_result = [0,0]
    if min_dt.blank?
      return empty_result
    end
    following = false
    ((max_dt-min_dt)/duration.to_f).ceil.times do |i|
      frame_from = (i==0 ? min_dt : min_dt + 1) + duration * i
      frame_till = [min_dt + duration * (i+1),max_dt].min
      if following
        return [frame_from,frame_till]
      end
      if (frame_from..frame_till).include?(timestamp)
        sql = "select min(race_dt) from races where start_date='#{date}' and race_dt between #{frame_from} and #{frame_till}"
        if ActiveRecord::Base.connection.execute(sql).values[0][0].to_i <= timestamp
          following = true
          next
        else
          return [frame_from,frame_till]
        end
      end
    end
    empty_result
  end

  def self.get_track_count(date)
    sql = "select track_id from races where start_date='#{date}' group by track_id"
    ActiveRecord::Base.connection.execute(sql).values.size
  end

  def self.process_eightball(start_date,timestamp)
    y,m,d = start_date.split('-').map(&:to_i)
    open_ts =Time.new(y,m,d,9,45,0,'+11:00').to_i
    result = {default_text:'check after 10 am',start_date:start_date,timestamp:timestamp,open_at:open_ts}
    result[:data] = result[:default_text]
    sql = "select min(race_dt),max(race_dt) from races where start_date='#{start_date}'"
    min_dt,max_dt = ActiveRecord::Base.connection.execute(sql).values[0]
    if min_dt.nil?
      result[:error] = 'No data founded for start_date'
      return result
    end
    result[:min_dt] = min_dt
    result[:max_dt] = max_dt
    result[:track_count] = get_track_count(start_date)
    unless (result[:open_at]..result[:max_dt]).include?(timestamp)
      result[:error] = 'Timestamp is outer specified date races'
      return result
    end
    result[:duration] = get_frame_duration(result[:track_count])
    result[:frame_start_at],result[:frame_end_at] = get_frame_borders(result[:start_date],result[:duration],result[:timestamp])
    sql = "select t.title||' R'||r.race_number||' No '||hp.horse_number
      from races r
      join tracks t on t.id=r.track_id
      join horse_positions hp on hp.score_position_reordered in (1,2) and hp.race_id=r.id
      join fluctuations f on f.race_id=r.id and f.horse_number=hp.horse_number
      join race_tabs rt on rt.race_id=r.id
      join race_classes rc on rc.title=rt.race_class
      where r.race_dt between #{result[:frame_start_at]} and #{result[:frame_end_at]} and r.start_date='#{result[:start_date]}'
      order by case when r.id in (
        select race_id
        from (
          select
          p.race_id
          from races r
          join tracks t on r.track_id=t.id
          join participates p on r.id=p.race_id
          join horse_positions hp on p.race_id=hp.race_id and p.horse_number=hp.horse_number and hp.score_position_reordered=1
          join participates px on px.horse_id=p.horse_id and coalesce(px.finished,'')<>'' and (position('L' in px.margin)>0 or px.finished='1')
          join races rx on rx.id=px.race_id and rx.start_date<r.start_date
          where r.start_date='#{result[:start_date]}'
        )x
        group by race_id
        having count(*)>=5
        order by get_race_class(race_id) desc
        limit 5
      ) then 1 else 0 end desc,f.current_price-f.open_price,rc.rank desc
      limit 1"
    value = ActiveRecord::Base.connection.execute(sql).values.flatten[0].to_s
    result[:data] = value.blank? ? 'Check back at TIME' : value
    result
  end







  def self.process_eightball_v1(start_date,timestamp)
    y,m,d = start_date.split('-').map(&:to_i)
    open_ts =Time.new(y,m,d,9,45,0,'+11:00').to_i
    result = {default_text:'check after 10 am',start_date:start_date,timestamp:timestamp,open_at:open_ts}
    result[:data] = result[:default_text]
    sql = "select min(race_dt),max(race_dt),min(extract(dow from start_date)),(select count(*) from (select distinct track_id from races where start_date='#{start_date}')x) from races where start_date='#{start_date}'"
    min_dt,max_dt,weekday,track_count = ActiveRecord::Base.connection.execute(sql).values[0]
    if min_dt.nil?
      result[:error] = 'No data founded for start_date'
      return result
    end
    result[:min_dt] = min_dt
    result[:max_dt] = max_dt
    result[:weekday] = weekday.zero? ? 7 : weekday
    result[:track_count] = track_count
    unless (result[:open_at]..result[:max_dt]).include?(timestamp)
      result[:error] = 'Timestamp is outer specified date races'
      return result
    end
    if result[:track_count]>=5
      result[:duration] = 20
    elsif result[:track_count]==4
      result[:duration] = 30
    else
      result[:duration] = 45
    end

    if result[:track_count]>2
      result[:frame_size] = ([3,6,7].include?(result[:weekday]) ? 20 : 45) * 60
      result[:frame_start_at] = [result[:min_dt],result[:timestamp]].max
      result[:frame_end_at] = result[:frame_start_at] + result[:frame_size]
      sql = "select t.title||' R'||r.race_number||' No '||hp.horse_number
      from races r
      join tracks t on t.id=r.track_id
      join horse_positions hp on hp.score_position_reordered in (1,2) and hp.race_id=r.id
      join fluctuations f on f.race_id=r.id and f.horse_number=hp.horse_number
      join race_tabs rt on rt.race_id=r.id
      join race_classes rc on rc.title=rt.race_class
      where r.race_dt between #{result[:frame_start_at]} and #{result[:frame_end_at]} and r.start_date='#{result[:start_date]}'
      order by case when r.id in (
        select race_id
        from (
          select
          p.race_id
          from races r
          join tracks t on r.track_id=t.id
          join participates p on r.id=p.race_id
          join horse_positions hp on p.race_id=hp.race_id and p.horse_number=hp.horse_number and hp.score_position_reordered=1
          join participates px on px.horse_id=p.horse_id and coalesce(px.finished,'')<>'' and (position('L' in px.margin)>0 or px.finished='1')
          join races rx on rx.id=px.race_id and rx.start_date<r.start_date
          where r.start_date='#{result[:start_date]}'
        )x
        group by race_id
        having count(*)>=5
        order by get_race_class(race_id) desc
        limit 5
      ) then 1 else 0 end desc,f.current_price-f.open_price,rc.rank desc
      limit 1"
    else
      result[:bundle_size] = 3
      sql = "select title
      from (
        select t.title||' R'||r.race_number||' No '||hp.horse_number as title,f.current_price,f.open_price,rc.rank,r.id
        from races r
        join tracks t on t.id=r.track_id
        join horse_positions hp on hp.score_position_reordered in (1,2) and hp.race_id=r.id
        join fluctuations f on f.race_id=r.id and f.horse_number=hp.horse_number
        join race_tabs rt on rt.race_id=r.id
        join race_classes rc on rc.title=rt.race_class
        where r.race_dt between #{result[:timestamp]} and #{result[:max_dt]} and r.start_date='#{result[:start_date]}'
        order by r.race_dt
        limit #{result[:bundle_size]}
      )x
      order by case when r.id in (
        select race_id
        from (
          select
          p.race_id
          from races r
          join tracks t on r.track_id=t.id
          join participates p on r.id=p.race_id
          join horse_positions hp on p.race_id=hp.race_id and p.horse_number=hp.horse_number and hp.score_position_reordered=1
          join participates px on px.horse_id=p.horse_id and coalesce(px.finished,'')<>'' and (position('L' in px.margin)>0 or px.finished='1')
          join races rx on rx.id=px.race_id and rx.start_date<r.start_date
          where r.start_date='#{result[:start_date]}'
        )x
        group by race_id
        having count(*)>=5
        order by get_race_class(race_id) desc
        limit 5
      ) then 1 else 0 end desc,current_price-open_price,rank desc
      limit 1"
    end
    value = ActiveRecord::Base.connection.execute(sql).values.flatten[0].to_s
    result[:data] = value.blank? ? 'Check back at TIME' : value
    result
  end
end
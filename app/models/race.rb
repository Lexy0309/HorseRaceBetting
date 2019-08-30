class Race < ApplicationRecord
  has_many :participates
  belongs_to :track
  has_one :race_tab
  has_one :rail_detail
  has_one :track_stat
  has_many :participate_details
  has_many :horse_positions
  has_one :race_reward
  has_one :race_position
  has_many :fluctuations
  belongs_to :horse
  belongs_to :jockey
  has_many :bet_races
  has_many :race_tips
  has_one :race_pool

  def full_title
    "#{track.blank? ? '' : track.title} #{start_date} R#{race_number} #{title}"
  end

  def short_title
    "#{track.title} R#{race_number}"
  end

  def full_condition
    (race_tab.nil? or race_tab.condition.blank?) ? race_class : race_tab.condition
  end

  def full_race_class
    (race_tab.nil? or race_tab.race_class.blank?) ? condition : race_tab.race_class
  end

  def full_number
    "R#{race_number}"
  end

  def next_race
    return @next unless @next.nil?
    data = Race.where(race_number:race_number+1,track_id:track_id,start_date:start_date)
    if data.any?
      @next = data[0].id
    else
      @next = 0
    end
  end

  def prev_race
    return @prev unless @prev.nil?
    data = Race.where(race_number:race_number-1,track_id:track_id,start_date:start_date)
    if data.any?
      @prev = data[0].id
    else
      @prev = 0
    end
  end

  def get_block
    result = []
    unless track.nil?
      result << ['Track',track.title]
    end
    result << ['Title',title.to_s]
    result << ['Distance',distance]
    result << ['Race number',race_number]
    result << ['Condition',full_condition]
    result << ['Full race class',condition]
    result << ['Race class',race_tab.race_class] if race_tab
    result << ['Rail',rail]
    result << ['Duration',duration.to_s]
    result << ['Date',start_date]
    result << ['Exact date',race_time] unless race_dt.to_i.zero?
    race_tips.each do |tip|
      result << ["Tips (#{RaceTip.sources[tip.source]})","#{tip.place1} #{tip.place2} #{tip.place3} #{tip.place4}"]
    end
    result
  end

  def race_time(offset=10)
    race_dt.to_i.zero? ? '' : Time.at(race_dt).in_time_zone(offset).strftime('%I:%M%p')
  end


  def get_info
    result = []
    details = []
    details << full_condition
    details << race_tab.race_class unless race_tab.nil?
    details << (distance.blank? ? '' : "#{distance}m")
    details << race_time
    result << ['race',full_title]
    result << ['details',details.join(' - ')]
    result << ['class',condition]
    result << ['rail',rail]
    result
  end


  def top_horses
    horse_positions.where(score_position_reordered:[1,2,3,4]).order(:score_position_reordered).includes(:horse)
  end

  def participate_bets
    result = {}
    participate_details.each do |detail|
      result[detail.horse_number] = detail
    end
    result
  end

  def participate_horse_positions
    result = {}
    horse_positions.each do |hp|
      result[hp.horse_number] = hp
    end
    result
  end

  def get_bet_block
    result = {}
    duets = []
    bets = %w[quinella exacta trifecta running_double daily_double quaddie first_four early_quaddie]
    participate_details.each do |detail|
      bets.each_with_index do |title,index|
        fulltitle = title.gsub('_',' ').titleize
        unless detail.send(title).to_i.zero?
          if result.include?(fulltitle)
            result[fulltitle][:items] << detail.horse_number
          else
            obj = {items:[detail.horse_number],value:detail.send(title),order:index}
            if %w[running_double daily_double quaddie early_quaddie].include?(title)
              obj[:text] = detail.send("#{title}_text")
            end
            result[fulltitle] = obj
          end
        end
      end
      unless detail.duet.to_i.zero?
        duets << {items:[detail.horse_number,detail.duet_pair],value:detail.duet,order:1.5}
      end
    end
    duets.each_with_index do |duet,index|
      title = "Duet #{index+1}"
      result[title] = duet
      result[title][:order] += index*0.1
    end
    result.each_key do |key|
      if result[key].include?(:text)
        result[key][:items] = result[key][:text]
      else
        result[key][:items] = result[key][:items].sort.join('-')
      end
    end
    result.to_a.sort_by{|x| (x[1][:order])}
  end

  def get_place_block
    result = []
    filtered = participate_details.select{|pd| pd.position.to_i > 0}
    if filtered.any?
      filtered.sort_by{|pd| pd.position}.each_with_index do |pd,index|
        result << {win:pd.fixed_odd_win,place:pd.fixed_odd_place,number:pd.horse_number,index:(index+1).ordinalize}
      end
    end
    result
  end

  def self.score_fields
    ['Barrier win','Run type','Win rate','Margin avg','Jockey win','Trainer win','Class avg','Best class','Price','Empty']
  end

  def self.outlier_fields
    {
        1=>'J&H',2=>'1st spell',3=>'2nd spell',4=>'3rd spell',5=>'T&J',6=>'Track&D',7=>'C&D',8=>'Cond',9=>'Track',10=>'Position',
        11=>'<M',12=>'RN 1st',13=>'RN 2nd',14=>'TAB 1st',15=>'C-30',16=>'TAB 2nd',17=>'<<M',18=>'Jump',19=>'Turn'
    }
  end



  def score_fields_list
    race_position.nil? ? [] : race_position.score_fields.to_s.split('-').map(&:to_i)
  end

  def ml_top
    race_position.nil? ? 0 : race_position.ml_top.to_i
  end

  def participates_js(order)
    #0 - default by horse_number; 1 - barrier; 2 - winrate info2; 3 - fluctuation; 4 - rank
    #5 - barrier winrate; 6 - jockey winrate; 7 - trainer winrate; 8 - margin avg; 9 - jump avg; 10 - turn avg
    field_count = 10
    sql = "select h.id,p.horse_number,h.title,p.sex,p.weight,p.barrier,coalesce(j.title,''),coalesce(t.title,''),p.age,coalesce(p.history,'f'),coalesce(scratched,0),coalesce(pd.fixed_odd_win,0),coalesce(pd.fixed_odd_place,0)
          ,coalesce(hp.score/10,0),coalesce(hp.score_position,0),coalesce(p.distance_wins,''),coalesce(previous_inrun,'')
          ,coalesce(f.open_price,0),coalesce(f.highest_price,0),coalesce(f.lowest_price,0),coalesce(f.current_price,0),coalesce(j.id,0),coalesce(t.id,0)
          #{field_count.times.map{|i| ",coalesce(score#{i+1},0),coalesce(score#{i+1}info1,''),coalesce(score#{i+1}info2,'')"}.join('')}
          from races r
          join participates p on r.id=p.race_id
          join horses h on h.id=p.horse_id
          left join jockeys j on j.id=p.jockey_id
          left join trainers t on t.id=p.trainer_id
          left join horse_positions hp on hp.race_id=r.id and hp.horse_number=p.horse_number
          left join participate_details pd on pd.race_id=r.id and pd.horse_number=p.horse_number
          left join fluctuations f on f.race_id=r.id and f.horse_number=p.horse_number
          where r.id=#{id} "
    if order==1
      sql << 'order by p.barrier'
    elsif order==2
      sql << "order by nullif(regexp_replace(score3info1, '\\D', '', 'g'), '')::int desc"
    elsif order==3
      sql << 'order by case when coalesce(f.open_price,0)=0 then 100 else round((coalesce(f.current_price,0)-f.open_price)/f.open_price*100) end'
    elsif order==4
      sql << 'order by score_position'
    elsif order==5
      sql << "order by nullif(regexp_replace(score1info1, '\\D', '', 'g'), '')::int desc"
    elsif order==6
      sql << "order by nullif(regexp_replace(score5info1, '\\D', '', 'g'), '')::int desc"
    elsif order==7
      sql << "order by nullif(regexp_replace(score6info1, '\\D', '', 'g'), '')::int desc"
    elsif order==8
      sql <<  "order by nullif(regexp_replace(score4info1, '\\D', '', 'g'), '')::int"
    elsif order==9
      sql <<  "order by nullif(regexp_replace(score9info1, '\\D', '', 'g'), '')::int"
    elsif order==10
      sql <<  "order by nullif(regexp_replace(score10info1, '\\D', '', 'g'), '')::int"
    else
      sql << 'order by p.horse_number'
    end
    sql << ',p.horse_number'

    titles = %w[
      horse_id horse_number horse_title sex weight barrier jockey_title trainer_title age history scratched win place total score_position distance_wins previous_inrun
      open_price highest_price lowest_price current_price jockey_id trainer_id
    ]
    field_count.times.map do |i|
      titles << "score#{i+1}"
      titles << "score#{i+1}info1"
      titles << "score#{i+1}info2"
    end
    values = ActiveRecord::Base.connection.execute(sql).values.map do |row|
      obj = {}
      row.size.times do |i|
        obj[titles[i]] = row[i]
      end
      obj[:details] = {race:"#{track.title} R#{race_number} #{start_date}",runner:"#{obj['horse_number']}. #{obj['horse_title']}",rank:obj['score_position'],win:obj['win'],place:obj['place']}
      obj[:image] = Participate.image_name(id,obj['horse_number'])
      obj
    end
    values
  end

  def get_fluctuations
    participates_id = {}
    participates.each do |p|
      participates_id[p.horse_number] = p.id
    end
    result = {}
    fluctuations.each do |f|
      id = participates_id[f.horse_number].to_i
      unless id.zero?
        result[id] = f
      end
    end
    result
  end

  def positions
    participates_id = {}
    participates.each do |p|
      participates_id[p.horse_number] = p.id
    end
    result = {}
    horse_positions.each do |hp|
      id = participates_id[hp.horse_number].to_i
      unless id.zero?
        result[id] = hp
      end
    end
    result
  end

  def get_summary
    result = []
    result << (best_position.blank? ? '' : "Barrier #{best_position}: #{(best_position_value*100).round}%")
    result << (jockey.nil? ? '' : "#{jockey.title}: #{(jockey_winrate_value*100).round}%")
    #result << (horse.nil? ? '' : "#{horse.title}: #{(horse_special_value*100).round}%")
    result
  end

  def self.get_class_strength(date)
    sql = "select max(rc.rank) from races r join race_tabs rt on rt.race_id=r.id join race_classes rc on rc.title=rt.race_class where r.start_date='#{date}'"
    max_value = ActiveRecord::Base.connection.execute(sql).values[0][0].to_i
    if max_value.zero?
      return {}
    end
    sql = "select r.id,round(100*rc.rank/(#{max_value}+0.0)) from races r join race_tabs rt on rt.race_id=r.id join race_classes rc on rc.title=rt.race_class where r.start_date='#{date}'"
    result = {}
    ActiveRecord::Base.connection.execute(sql).values.each do |race_id,value|
      result[race_id] = value
    end
    result
  end

  def self.get_prediction_strength(date)
    sql = "select r.id,case when sum(hp.score)=0 then 0 else round(100*sum(case when hp.score_position_reordered between 1 and 4 then hp.score else 0 end)/sum(hp.score+0.0)) end
from races r join horse_positions hp on r.id=hp.race_id where r.start_date='#{date}' group by r.id "
    result = {}
    ActiveRecord::Base.connection.execute(sql).values.each do |race_id,value|
      result[race_id] = value
    end
    result
  end
end

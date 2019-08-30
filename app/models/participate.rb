class Participate < ApplicationRecord
  belongs_to :horse
  belongs_to :jockey
  belongs_to :trainer
  belongs_to :race

  def horse_title
    horse.nil? ? '' : horse.title
  end

  def jockey_title
    jockey.nil? ? '' : jockey.title
  end

  def trainer_title
    trainer.nil? ? '' : trainer.title
  end

  def obj_title(obj)
    obj.nil? ? '' : obj.title
  end

  def obj_id(obj)
    obj.nil? ? 0 : obj.id

  end

  def self.daily_top(date,limit=5)
    sql = "select t.title,'R'||r.race_number,p.horse_number||'. '||h.title,hp.score
    from races r
    join participates p on p.race_id=r.id
    join horses h on h.id=p.horse_id
    join tracks t on t.id=r.track_id
    join horse_positions hp on hp.race_id=r.id and hp.horse_number=p.horse_number
    where start_date='#{date}'
    order by hp.score desc
    limit #{limit}"
    ActiveRecord::Base.connection.execute(sql).values
  end

  def self.daily_top_price(date,limit=5)
    sql = "select t.title,r.race_number,h.title,p.horse_number, pd.fixed_odd_win
    from participates p
    join horse_positions hp on p.race_id=hp.race_id and p.horse_number=hp.horse_number
    join participates px on p.race_id=px.race_id
    join horse_positions hpx on hpx.race_id=px.race_id and hp.score_position=hpx.score_position-1
    join races r on p.race_id=r.id
    join participate_details pd on pd.race_id=r.id and pd.horse_number=p.horse_number
    join tracks t on t.id=r.track_id
    join horses h on h.id=p.horse_id
    where start_date='#{date}' and pd.fixed_odd_win>=5 and hp.score_position=1
    order by coalesce(hp.score-hpx.score,0) desc
    limit #{limit}"
    ActiveRecord::Base.connection.execute(sql).values
  end

  def show_history
    history.blank? ? 'f' : history
  end

  def self.image_name(race_id,horse_number)
    filename = "/images/#{race_id}_#{horse_number}.png"
    path = "#{Rails.public_path}#{filename}"
    if FileTest.exist?(path)
      filename
    else
      '/images/no_image.png'
    end
  end
end

class Bet < ApplicationRecord
  has_many :bet_races
  CATEGORY_DATA =  {
      1=>{title:'Quinella',descr:'Select both horses in a Quinella bet'},
      #2=>'Quaddie',
      #3=>'Exacta 4',#
      4=>{title:'Exacta 3',descr:'Box all three selections in an exacta bet'},
      #5=>'Trifecta',
      #6=>'First four 1',
      #7=>'Trifecta 1',#
      #8=>'Trifecta 2',#
      #9=>'Trifecta 3',#
      #10=>'Trifecta 4',
      #11=>'Trifecta 5',
      12=>{title:'Win 1',descr:'Place a win bet on the selected horse(s)'},
      13=>{title:'Win 2',descr:'Select "doubles" or system 2 bet for the selected win bet. If at the same track this can be done as a Parlay'},
      #14=>'Win 3',
      #15=>'Win 4',
      16=>{title:'Win 5',descr:'Place this bet as "each way", bet 50% on the win and 50% on the place line'},
      #17=>'Win 6',
      18=>{title:'Win 7',descr:'Place a win bet on the selected horse(s)'},
      #19=>'Win 1 special',
      #20=>'Win 2 special',
      21=>{title:'Win 3 special',descr:'Select "Trebles" or system 3 bet for the selected win bet. If at the same track this can be done as a Parlay'},
      #22=>'Win 4 special',
      #23=>'Win 5 special',
      #24=>'Trifecta 6',
      25=>{title:'Trifecta 7',descr:'Box these 5 selections in a trifecta'},
      #26=>'Trifecta 8',
      #27=>'First four 2',
      28=>{title:'Win 8',descr:'Place a win bet on the selected horse(s) - Fixed'},
      29=>{title:'Win 9',descr:''},
      #30=>'Win 10',
      #31=>'Win 11',
      #32=>'Trifecta 9',
      33=>{title:'Special Double',descr:'Select both races as a race to race double. Both bets are Race 1 into Race 2 - win. The second leg is different bets in the same race. Only one bet can win'},
  }

  def self.category_title(category)
    CATEGORY_DATA.include?(category) ? CATEGORY_DATA[category][:title] : ''
  end

  def self.category_descr(category)
    CATEGORY_DATA.include?(category) ? CATEGORY_DATA[category][:descr] : ''
  end

  def category_title
    self.class.category_title(category)
  end

  def category_descr
    self.class.category_descr(category)
  end

  def full_title
    bet_races.map{|br| "#{br.race.track.title} R#{br.race.race_number} #{br.bet_horses.map(&:horse_number).join(' and ')}"}.join('; ')
  end

  def special_title
    bet_races.map{|br| "#{br.race.track.title} R#{br.race.race_number} #{br.bet_horses.map(&:horse_number).join(' and ')}"}.join(' into ')
  end

  def self.get_category_data(category,date)
    if category==1
      sql = """select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,pd1.position,pd1.fixed_odd_win
      ,bh2.horse_number,pd2.position,pd2.fixed_odd_win
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on r.id=br.race_id
      join tracks t on r.track_id=t.id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.horse_number=bh1.horse_number
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.horse_number=bh2.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==2
      sql = """select b.id,b.start_date,b.amount,b.reward
      ,t1.title||' R'||r1.race_number,bh11.horse_number,bh12.horse_number,bh13.horse_number,bh14.horse_number,pd11.position,pd12.position,pd13.position,pd14.position
      ,t2.title||' R'||r2.race_number,bh21.horse_number,bh22.horse_number,bh23.horse_number,bh24.horse_number,pd21.position,pd22.position,pd23.position,pd24.position
      ,t3.title||' R'||r3.race_number,bh31.horse_number,bh32.horse_number,bh33.horse_number,bh34.horse_number,pd31.position,pd32.position,pd33.position,pd34.position
      ,t4.title||' R'||r4.race_number,bh41.horse_number,bh42.horse_number,bh43.horse_number,bh44.horse_number,pd41.position,pd42.position,pd43.position,pd44.position
      from bets b
      join bet_races br1 on b.id=br1.bet_id and br1.special_order=1
      join bet_races br2 on b.id=br2.bet_id and br2.special_order=2
      join bet_races br3 on b.id=br3.bet_id and br3.special_order=3
      join bet_races br4 on b.id=br4.bet_id and br4.special_order=4
      join bet_horses bh11 on bh11.bet_race_id=br1.id and bh11.special_order=1
      join bet_horses bh12 on bh12.bet_race_id=br1.id and bh12.special_order=2
      left join bet_horses bh13 on bh13.bet_race_id=br1.id and bh13.special_order=3
      left join bet_horses bh14 on bh14.bet_race_id=br1.id and bh14.special_order=4

      join races r1 on r1.id=br1.race_id
      join races r2 on r2.id=br2.race_id
      join races r3 on r3.id=br3.race_id
      join races r4 on r4.id=br4.race_id

      join tracks t1 on t1.id=r1.track_id
      join tracks t2 on t2.id=r2.track_id
      join tracks t3 on t3.id=r3.track_id
      join tracks t4 on t4.id=r4.track_id

      join bet_horses bh21 on bh21.bet_race_id=br2.id and bh21.special_order=1
      join bet_horses bh22 on bh22.bet_race_id=br2.id and bh22.special_order=2
      left join bet_horses bh23 on bh23.bet_race_id=br2.id and bh23.special_order=3
      left join bet_horses bh24 on bh24.bet_race_id=br2.id and bh24.special_order=4

      join bet_horses bh31 on bh31.bet_race_id=br3.id and bh31.special_order=1
      join bet_horses bh32 on bh32.bet_race_id=br3.id and bh32.special_order=2
      left join bet_horses bh33 on bh33.bet_race_id=br3.id and bh33.special_order=3
      left join bet_horses bh34 on bh34.bet_race_id=br3.id and bh34.special_order=4

      join bet_horses bh41 on bh41.bet_race_id=br4.id and bh41.special_order=1
      join bet_horses bh42 on bh42.bet_race_id=br4.id and bh42.special_order=2
      left join bet_horses bh43 on bh43.bet_race_id=br4.id and bh43.special_order=3
      left join bet_horses bh44 on bh44.bet_race_id=br4.id and bh44.special_order=4

      left join participate_details pd11 on pd11.race_id=br1.race_id and pd11.horse_number=bh11.horse_number
      left join participate_details pd12 on pd12.race_id=br1.race_id and pd12.horse_number=bh12.horse_number
      left join participate_details pd13 on pd13.race_id=br1.race_id and pd13.horse_number=bh13.horse_number
      left join participate_details pd14 on pd14.race_id=br1.race_id and pd14.horse_number=bh14.horse_number

      left join participate_details pd21 on pd21.race_id=br2.race_id and pd21.horse_number=bh21.horse_number
      left join participate_details pd22 on pd22.race_id=br2.race_id and pd22.horse_number=bh22.horse_number
      left join participate_details pd23 on pd23.race_id=br2.race_id and pd23.horse_number=bh23.horse_number
      left join participate_details pd24 on pd24.race_id=br2.race_id and pd24.horse_number=bh24.horse_number

      left join participate_details pd31 on pd31.race_id=br3.race_id and pd31.horse_number=bh31.horse_number
      left join participate_details pd32 on pd32.race_id=br3.race_id and pd32.horse_number=bh32.horse_number
      left join participate_details pd33 on pd33.race_id=br3.race_id and pd33.horse_number=bh33.horse_number
      left join participate_details pd34 on pd34.race_id=br3.race_id and pd34.horse_number=bh34.horse_number

      left join participate_details pd41 on pd41.race_id=br4.race_id and pd41.horse_number=bh41.horse_number
      left join participate_details pd42 on pd42.race_id=br4.race_id and pd42.horse_number=bh42.horse_number
      left join participate_details pd43 on pd43.race_id=br4.race_id and pd43.horse_number=bh43.horse_number
      left join participate_details pd44 on pd44.race_id=br4.race_id and pd44.horse_number=bh44.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==3
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==4
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number
      ,pd1.horse_number,pd2.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==5
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number,bh5.horse_number,bh6.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      join bet_horses bh5 on bh5.bet_race_id=br.id and bh5.special_order=5
      join bet_horses bh6 on bh6.bet_race_id=br.id and bh6.special_order=6
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==6
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number,bh5.horse_number,bh6.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number,pd4.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      join bet_horses bh5 on bh5.bet_race_id=br.id and bh5.special_order=5
      join bet_horses bh6 on bh6.bet_race_id=br.id and bh6.special_order=6
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      left join participate_details pd4 on pd4.race_id=br.race_id and pd4.position=4
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==7
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==8
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==9
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==10
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number,bh5.horse_number,bh6.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      join bet_horses bh5 on bh5.bet_race_id=br.id and bh5.special_order=5
      join bet_horses bh6 on bh6.bet_race_id=br.id and bh6.special_order=6
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==11
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number,bh5.horse_number,bh6.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      join bet_horses bh5 on bh5.bet_race_id=br.id and bh5.special_order=5
      join bet_horses bh6 on bh6.bet_race_id=br.id and bh6.special_order=6
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif [12,19,28,29,30,31].include? category
      sql = """select b.id,b.start_date,b.amount,b.reward,t.title||' R'||r.race_number,r.id,bh.horse_number,pd.fixed_odd_win,pd.position
      from bets b
      join bet_races br on br.bet_id=b.id
      join bet_horses bh on bh.bet_race_id=br.id
      join races r on r.id=br.race_id
      join tracks t on t.id=r.track_id
      join participate_details pd on pd.race_id=r.id and pd.horse_number=bh.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif [13,20].include? category
      sql = """select b.id,to_char( b.start_date, 'dd-mm-yyyy'),b.start_date,b.amount,b.reward
      ,'R'||r1.race_number||' '||t1.title,bh1.horse_number,r1.id,pdx1.horse_number,pd1.fixed_odd_win
      ,'R'||r2.race_number||' '||t2.title,bh2.horse_number,r2.id,pdx2.horse_number,pd2.fixed_odd_win
      ,case when extract(isodow from b.start_date)=6 then 1 else 0 end
      from bets b
      join bet_races br1 on b.id=br1.bet_id and br1.special_order=1
      join races r1 on r1.id=br1.race_id
      join tracks t1 on t1.id=r1.track_id
      join bet_horses bh1 on bh1.bet_race_id=br1.id
      left join participate_details pd1 on pd1.race_id=br1.race_id and pd1.horse_number=bh1.horse_number
      left join participate_details pdx1 on pdx1.race_id=br1.race_id and pdx1.position=1
      join bet_races br2 on b.id=br2.bet_id and br2.special_order=2
      join races r2 on r2.id=br2.race_id
      join tracks t2 on t2.id=r2.track_id
      join bet_horses bh2 on bh2.bet_race_id=br2.id
      left join participate_details pd2 on pd2.race_id=br2.race_id and pd2.horse_number=bh2.horse_number
      left join participate_details pdx2 on pdx2.race_id=br2.race_id and pdx2.position=1
      where category=#{category} and b.start_date = '#{date}' order by b.special_order"""
    elsif [14,21].include? category
      sql = """select b.id,to_char( b.start_date, 'dd-mm-yyyy'),b.start_date,b.amount,b.reward
      ,'R'||r1.race_number||' '||t1.title,bh1.horse_number,r1.id,case when pd1.fixed_odd_win>10 then case when pd1.position in (1,2,3) then 1 else 0 end  else case when pd1.position=1 then 1 else 0 end end,case when pd1.fixed_odd_win>10 then pd1.fixed_odd_place else pd1.fixed_odd_win end
      ,'R'||r2.race_number||' '||t2.title,bh2.horse_number,r2.id,case when pd2.fixed_odd_win>10 then case when pd2.position in (1,2,3) then 1 else 0 end  else case when pd2.position=1 then 1 else 0 end end,case when pd2.fixed_odd_win>10 then pd2.fixed_odd_place else pd2.fixed_odd_win end
      ,'R'||r3.race_number||' '||t3.title,bh3.horse_number,r3.id,case when pd3.fixed_odd_win>10 then case when pd3.position in (1,2,3) then 1 else 0 end  else case when pd3.position=1 then 1 else 0 end end,case when pd3.fixed_odd_win>10 then pd3.fixed_odd_place else pd3.fixed_odd_win end
      from bets b
      join bet_races br1 on b.id=br1.bet_id and br1.special_order=1
      join races r1 on r1.id=br1.race_id
      join tracks t1 on t1.id=r1.track_id
      join bet_horses bh1 on bh1.bet_race_id=br1.id
      left join participate_details pd1 on pd1.race_id=br1.race_id and pd1.horse_number=bh1.horse_number
      left join participate_details pdx1 on pdx1.race_id=br1.race_id and pdx1.position=1
      join bet_races br2 on b.id=br2.bet_id and br2.special_order=2
      join races r2 on r2.id=br2.race_id
      join tracks t2 on t2.id=r2.track_id
      join bet_horses bh2 on bh2.bet_race_id=br2.id
      left join participate_details pd2 on pd2.race_id=br2.race_id and pd2.horse_number=bh2.horse_number
      left join participate_details pdx2 on pdx2.race_id=br2.race_id and pdx2.position=1
      join bet_races br3 on b.id=br3.bet_id and br3.special_order=3
      join races r3 on r3.id=br3.race_id
      join tracks t3 on t3.id=r3.track_id
      join bet_horses bh3 on bh3.bet_race_id=br3.id
      left join participate_details pd3 on pd3.race_id=br3.race_id and pd3.horse_number=bh3.horse_number
      left join participate_details pdx3 on pdx3.race_id=br3.race_id and pdx3.position=1
      where category=#{category} and b.start_date = '#{date}' order by b.special_order"""
    elsif [15,22].include? category
      sql = """select b.id,b.start_date,b.amount,b.reward,t.title||' R'||r.race_number,r.id,bh.horse_number,pd.fixed_odd_win,pd.position
      from bets b
      join bet_races br on br.bet_id=b.id
      join bet_horses bh on bh.bet_race_id=br.id
      join races r on r.id=br.race_id
      join tracks t on t.id=r.track_id
      join participate_details pd on pd.race_id=r.id and pd.horse_number=bh.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif [16,23].include? category
      sql = """select b.id,b.start_date,b.amount,b.reward,t.title||' R'||r.race_number,r.id,bh.horse_number,pd.fixed_odd_win,pd.fixed_odd_place,pd.position
      from bets b
      join bet_races br on br.bet_id=b.id
      join bet_horses bh on bh.bet_race_id=br.id
      join races r on r.id=br.race_id
      join tracks t on t.id=r.track_id
      join participate_details pd on pd.race_id=r.id and pd.horse_number=bh.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==17
      sql = """select b.id,b.start_date,b.amount,b.reward,t.title||' R'||r.race_number,r.id,bh.horse_number,pd.fixed_odd_win,pd.position
      from bets b
      join bet_races br on br.bet_id=b.id
      join bet_horses bh on bh.bet_race_id=br.id
      join races r on r.id=br.race_id
      join tracks t on t.id=r.track_id
      join participate_details pd on pd.race_id=r.id and pd.horse_number=bh.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==18
      sql = """select b.id,b.start_date,b.amount,b.reward,t.title||' R'||r.race_number,r.id,bh.horse_number,pd.fixed_odd_win,pd.position
      from bets b
      join bet_races br on br.bet_id=b.id
      join bet_horses bh on bh.bet_race_id=br.id
      join races r on r.id=br.race_id
      join tracks t on t.id=r.track_id
      join participate_details pd on pd.race_id=r.id and pd.horse_number=bh.horse_number
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==24
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==25
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number,bh5.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      join bet_horses bh5 on bh5.bet_race_id=br.id and bh5.special_order=5
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==26
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==27
      sql = """
      select b.id,b.start_date,b.amount,b.reward
      ,'R'||r.race_number||' '||t.title,br.race_id
      ,bh1.horse_number,bh2.horse_number,bh3.horse_number,bh4.horse_number
      ,pd1.horse_number,pd2.horse_number,pd3.horse_number,pd4.horse_number
      from bets b
      join bet_races br on b.id=br.bet_id
      join races r on br.race_id=r.id
      join tracks t on t.id=r.track_id
      join bet_horses bh1 on bh1.bet_race_id=br.id and bh1.special_order=1
      join bet_horses bh2 on bh2.bet_race_id=br.id and bh2.special_order=2
      join bet_horses bh3 on bh3.bet_race_id=br.id and bh3.special_order=3
      join bet_horses bh4 on bh4.bet_race_id=br.id and bh4.special_order=4
      left join participate_details pd1 on pd1.race_id=br.race_id and pd1.position=1
      left join participate_details pd2 on pd2.race_id=br.race_id and pd2.position=2
      left join participate_details pd3 on pd3.race_id=br.race_id and pd3.position=3
      left join participate_details pd4 on pd4.race_id=br.race_id and pd4.position=4
      where category=#{category} and b.start_date='#{date}'"""
    elsif category==33
      sql = """select b.id,to_char( b.start_date, 'dd-mm-yyyy'),b.start_date,b.amount,b.reward
      ,'R'||r1.race_number||' '||t1.title,bh1.horse_number,r1.id,pdx1.horse_number,pd1.fixed_odd_win
      ,'R'||r2.race_number||' '||t2.title,bh21.horse_number,r2.id,pdx21.horse_number,pd21.fixed_odd_win
      ,'R'||r2.race_number||' '||t2.title,bh22.horse_number,r2.id,pdx22.horse_number,pd22.fixed_odd_win
      from bets b
      join bet_races br1 on b.id=br1.bet_id and br1.special_order=1
      join races r1 on r1.id=br1.race_id
      join tracks t1 on t1.id=r1.track_id
      join bet_horses bh1 on bh1.bet_race_id=br1.id
      left join participate_details pd1 on pd1.race_id=br1.race_id and pd1.horse_number=bh1.horse_number
      left join participate_details pdx1 on pdx1.race_id=br1.race_id and pdx1.position=1
      join bet_races br2 on b.id=br2.bet_id and br2.special_order=2
      join races r2 on r2.id=br2.race_id
      join tracks t2 on t2.id=r2.track_id
      join bet_horses bh21 on bh21.bet_race_id=br2.id and bh21.special_order=1
      left join participate_details pd21 on pd21.race_id=br2.race_id and pd21.horse_number=bh21.horse_number
      left join participate_details pdx21 on pdx21.race_id=br2.race_id and pdx21.position=1
      join bet_horses bh22 on bh22.bet_race_id=br2.id and bh22.special_order=2
      left join participate_details pd22 on pd22.race_id=br2.race_id and pd22.horse_number=bh22.horse_number
      left join participate_details pdx22 on pdx22.race_id=br2.race_id and pdx22.position=1
      where category=#{category} and b.start_date = '#{date}' order by b.special_order"""
    else
      sql = ''
    end
    if sql.blank?
      []
    else
      ActiveRecord::Base.connection.execute(sql).values
    end
  end
end

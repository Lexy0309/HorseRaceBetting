# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
State.delete_all
['NSW', 'SA', 'QLD', 'WA', 'VIC', 'ACT', 'NT', 'TAS'].each_with_index do |state,index|
  State.create(title:state,id:index+1)
end

Bookmaker.delete_all
%w[Neds Ladbrokes Beteasy TAB Sportsbet Others].each_with_index do |title,index|
  Bookmaker.create(id:index+1,title:title)
end

users = [
    {email:'89anisim89@mail.ru',password:'156400'},
    {email:'paul_gradwell@gmail.com',password:'147082'},
    {email:'cfpabuda@gmail.com',password:'087361'},
    {email:'armaansoni26021990@gmail.com',password:'974991'},
    {email:'jitendra@narola.email',password:'3492847127'},
    {email: 'goldmind2018@gmail.com',password:'32928103'},
    {email:'gloweve1220@gmail.com',password:'83445901'}
]
users.each do |user|
  User.where(email: user[:email]).delete_all
  User.create(email:user[:email],password:user[:password],password_confirmation:user[:password],is_admin: true)
end

plans = [
    {
      payment_gateway_plan_identifier: "pineapples_tier_1",
      name: "Pineapples",
      price_cents: 3848,
      interval: "month",
      interval_count: 1,
      description: "
      <ul>
        <li>Quaddie numbers</li>
        <li>exotic numbers (Trifectas, first fours)</li>
        <li>betting markets 2 per day + 6 for Wed/Thur/Fri + 6-10 for Sat/Sun</li>
        <li>Forum + admin best bets posted - Tuesday for Wednesday + Thursday for Saturday</li>
        <li>Futures betting advice</li>
        <li>Upcoming feature racing calendar</li>
        <li>All Group 1's reviewed plus betting strategies</li>
        <li>Opt in to email out all the above? + annoucements + how to?</li>
      </ul>"
    },
    {
      payment_gateway_plan_identifier: "gorillas_tier_2",
      name: "Gorillas",
      price_cents: 8181,
      interval: "month",
      interval_count: 1,
      description: "
      <ul>
        <li>Quaddie numbers</li>
        <li>exotic numbers (Trifectas, first fours)</li>
        <li>betting markets 2 per day + 6 for Wed/Thur/Fri + 6-10 for Sat/Sun</li>
        <li>Forum + admin best bets posted - Tuesday for Wednesday + Thursday for Saturday</li>
        <li>Futures betting advice</li>
        <li>Upcoming feature racing calendar</li>
        <li>All Group 1's reviewed plus betting strategies</li>
        <li>Opt in to email out all the above? + annoucements + how to?</li>
      </ul>"
    },
    {
      payment_gateway_plan_identifier: "magic_eightball_tier_3",
      name: "Magic Eightball",
      price_cents: 1000,
      interval: "day",
      interval_count: 3,
      description: "
      <ul>
        <li>Quaddie numbers</li>
        <li>exotic numbers (Trifectas, first fours)</li>
        <li>betting markets 2 per day + 6 for Wed/Thur/Fri + 6-10 for Sat/Sun</li>
        <li>Forum + admin best bets posted - Tuesday for Wednesday + Thursday for Saturday</li>
        <li>Futures betting advice</li>
        <li>Upcoming feature racing calendar</li>
        <li>All Group 1's reviewed plus betting strategies</li>
        <li>Opt in to email out all the above? + annoucements + how to?</li>
      </ul>"
    }
]
Plan.transaction do
  begin
    plans.each do |plan|
      PaymentGateway::CreatePlanService.new(**plan).run
    end
  rescue => e
    puts "Error message: #{e.message}"
  end
end

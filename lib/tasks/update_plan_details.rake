namespace :update_plan_details do
  task :update => :environment do
    Plan.find_by(payment_gateway_plan_identifier: "pineapples_tier_1").update(description: "<ul><li>Daily tips pushed to your account
    <li>First four numbers</li>
    <li>Quaddie Numbers</li>
    <li>Magic eight ball</li>
    <li>Best betting markets</li>
    <li>Bets strength per race</li></ul>", price_cents: "888", interval: "week", interval_count: "billed weekly")

    Plan.find_by(payment_gateway_plan_identifier: "gorillas_tier_2").update(description: "<ul><li>All the Pineapples membership benefits</li>
    <li>Proven winning bet strategies tailored to your bank and betting days</li>
    <li>Black book access (ours + yours)</li></ul>", price_cents: "1888", interval: "week", interval_count: "billed weekly")

    Plan.find_by(payment_gateway_plan_identifier: "magic_eightball_tier_3").update(description: "<ul><li>Tips provided based on proprietarty algorithms dilvered in the click of a button. You can’t do the form, let the eightball pick the winners for you!</li>
    <li>(also included in memberships)</li></ul>", price_cents: "1000", interval: "3", interval_count: "days (1 day + 2 days free)")
  end
end

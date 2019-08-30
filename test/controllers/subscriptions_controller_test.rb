require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get subscribe" do
    get subscriptions_subscribe_url
    assert_response :success
  end

end

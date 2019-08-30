require 'test_helper'

class DailyTipsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get daily_tips_index_url
    assert_response :success
  end

end

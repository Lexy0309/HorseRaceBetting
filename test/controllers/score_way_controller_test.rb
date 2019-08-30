require 'test_helper'

class ScoreWayControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get score_way_index_url
    assert_response :success
  end

end

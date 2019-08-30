require 'test_helper'

class JockeyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jockey_index_url
    assert_response :success
  end

end

require 'test_helper'

class HorseControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get horse_show_url
    assert_response :success
  end

end

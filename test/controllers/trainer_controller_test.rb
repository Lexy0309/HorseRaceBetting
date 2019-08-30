require 'test_helper'

class TrainerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trainer_index_url
    assert_response :success
  end

end

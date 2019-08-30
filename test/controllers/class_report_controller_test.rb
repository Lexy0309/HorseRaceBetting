require 'test_helper'

class ClassReportControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get class_report_index_url
    assert_response :success
  end

end

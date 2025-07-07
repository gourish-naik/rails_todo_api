require "test_helper"

class TodoDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get todo_details_show_url
    assert_response :success
  end

  test "should get update" do
    get todo_details_update_url
    assert_response :success
  end

  test "should get destroy" do
    get todo_details_destroy_url
    assert_response :success
  end
end

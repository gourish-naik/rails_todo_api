require "test_helper"

class Api::WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_webhooks_create_url
    assert_response :success
  end
end

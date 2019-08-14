require 'test_helper'

class FlightsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get flights_new_url
    assert_response :success
  end

end

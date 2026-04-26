require "test_helper"

class PricesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @bitcoin = prices(:bitcoin)
  end

  test "index returns all prices" do
    get prices_url
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert_equal Price.count, json_response.length
    
    # Check structure of first item
    item = json_response.first
    assert_includes item.keys, "name"
    assert_includes item.keys, "symbol"
    assert_includes item.keys, "price"
  end

  test "index enqueues AddCoinsJob when no prices exist" do
    Price.delete_all
    assert_enqueued_with(job: AddCoinsJob) do
      get prices_url
    end
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "No coins found at this moment. Please try after some time", json_response["error"]
  end

  test "show returns price for valid symbol" do
    get price_url(@bitcoin.coin_symbol)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @bitcoin.coin_name, json_response["name"]
    assert_equal @bitcoin.coin_symbol, json_response["symbol"]
  end

  test "show returns 404 for invalid symbol" do
    get price_url("invalid_symbol")
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Price not found", json_response["error"]
  end
end

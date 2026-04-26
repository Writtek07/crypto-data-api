require "test_helper"

class CoinGeckoServiceTest < ActiveSupport::TestCase
  test "fetch_coins_data returns list of coins on success" do
    url = "https://api.coingecko.com/api/v3/coins/list"
    stub_request(:get, url).to_return(
      status: 200, 
      body: '[{"id": "bitcoin", "symbol": "btc", "name": "Bitcoin"}]', 
      headers: { "Content-Type" => "application/json" }
    )

    result = CoinGeckoService.fetch_coins_data
    assert_equal 1, result.length
    assert_equal "bitcoin", result.first["id"]
  end

  test "fetch_coins_data returns empty array on failure" do
    url = "https://api.coingecko.com/api/v3/coins/list"
    stub_request(:get, url).to_return(status: 500)

    result = CoinGeckoService.fetch_coins_data
    assert_equal [], result
  end

  test "fetch_coin_price returns price on success" do
    symbol = "btc"
    url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&symbols=#{symbol}&precision=10"
    stub_request(:get, url).to_return(
      status: 200, 
      body: '[{"current_price": 50000.0}]', 
      headers: { "Content-Type" => "application/json" }
    )

    result = CoinGeckoService.fetch_coin_price(symbol)
    assert_equal 50000.0, result
  end

  test "fetch_coin_price returns nil on failure" do
    symbol = "btc"
    url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&symbols=#{symbol}&precision=10"
    stub_request(:get, url).to_return(status: 404)

    result = CoinGeckoService.fetch_coin_price(symbol)
    assert_nil result
  end
end

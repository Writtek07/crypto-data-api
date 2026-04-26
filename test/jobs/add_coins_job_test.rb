require "test_helper"

class AddCoinsJobTest < ActiveJob::TestCase
  test "fetch_coins enqueues save_coin_data jobs on success" do
    coins_data = [
      { "id" => "bitcoin", "symbol" => "btc", "name" => "Bitcoin" },
      { "id" => "ethereum", "symbol" => "eth", "name" => "Ethereum" }
    ]
    CoinGeckoService.stub :fetch_coins_data, coins_data do
      assert_enqueued_jobs 2 do
        AddCoinsJob.perform_now({ action: "fetch_coins" })
      end
    end
  end

  test "fetch_coins retries itself if API returns empty" do
    CoinGeckoService.stub :fetch_coins_data, [] do
      assert_enqueued_jobs 1 do
        AddCoinsJob.perform_now({ action: "fetch_coins" })
      end
    end
  end

  test "save_coin_data creates a new Price record" do
    coin_data = { "symbol" => "sol", "name" => "Solana" }
    assert_difference "Price.count", 1 do
      AddCoinsJob.perform_now({ action: "save_coin_data", coin: coin_data })
    end
    price = Price.find_by(coin_symbol: "sol")
    assert_equal "Solana", price.coin_name
  end

  test "save_coin_data does not create duplicate Price record" do
    existing = prices(:bitcoin)
    coin_data = { "symbol" => existing.coin_symbol, "name" => existing.coin_name }
    assert_no_difference "Price.count" do
      AddCoinsJob.perform_now({ action: "save_coin_data", coin: coin_data })
    end
  end
end

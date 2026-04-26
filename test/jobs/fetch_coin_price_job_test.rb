require "test_helper"

class FetchCoinPriceJobTest < ActiveJob::TestCase
  def setup
    @bitcoin = prices(:bitcoin)
    @ethereum = prices(:ethereum)
  end

  test "queue_price_fetch enqueues individual fetch jobs" do
    assert_enqueued_jobs Price.count do
      FetchCoinPriceJob.perform_now({ "action" => "queue_price_fetch" })
    end
  end

  test "fetch_price_and_cache updates price on success" do
    # Mocking CoinGeckoService to return a specific price
    CoinGeckoService.stub :fetch_coin_price, 52000.0 do
      FetchCoinPriceJob.perform_now({ "action" => "fetch_price_and_cache", "price_id" => @bitcoin.id })
      @bitcoin.reload
      assert_equal 52000.0, @bitcoin.latest_price
      assert_not_nil @bitcoin.last_price_fetch_at
    end
  end

  test "fetch_price_and_cache does not update price on failure" do
    original_price = @bitcoin.latest_price
    # Mocking CoinGeckoService to return nil
    CoinGeckoService.stub :fetch_coin_price, nil do
      FetchCoinPriceJob.perform_now({ "action" => "fetch_price_and_cache", "price_id" => @bitcoin.id })
      @bitcoin.reload
      assert_equal original_price, @bitcoin.latest_price
    end
  end

  test "perform raises error if action is missing" do
    assert_raises(RuntimeError, "Action is not defined") do
      FetchCoinPriceJob.perform_now({})
    end
  end
end

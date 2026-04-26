require "test_helper"

class PriceTest < ActiveSupport::TestCase
  def setup
    @price = prices(:bitcoin)
    Rails.cache.clear
  end

  test "should be valid" do
    assert @price.valid?
  end

  test "coin_name should be present" do
    @price.coin_name = ""
    assert_not @price.valid?
  end

  test "coin_symbol should be present" do
    @price.coin_symbol = ""
    assert_not @price.valid?
  end

  test "coin_name should be unique" do
    duplicate_price = @price.dup
    @price.save
    assert_not duplicate_price.valid?
  end

  test "coin_symbol should be unique" do
    duplicate_price = @price.dup
    @price.save
    assert_not duplicate_price.valid?
  end

  test "should cache price after save" do
    @price.latest_price = 55000.0
    @price.save
    cached_price = Rails.cache.read(@price.price_cache_key)
    assert_equal 55000.0, cached_price
  end

  test "fetch_latest_price should return cached price if available" do
    @price.latest_price = 60000.0
    Rails.cache.write(@price.price_cache_key, 65000.0)
    assert_equal 65000.0, @price.fetch_latest_price
  end

  test "fetch_latest_price should return latest_price if cache is empty" do
    @price.latest_price = 60000.0
    assert_equal 60000.0, @price.fetch_latest_price
  end

  test "as_json should return correct structure" do
    json = @price.as_json
    assert_equal "Bitcoin", json[:name]
    assert_equal "btc", json[:symbol]
    assert_equal 50000.0, json[:price]
  end
end

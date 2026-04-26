class Price < ApplicationRecord
  validates :coin_name, :coin_symbol, presence: true, uniqueness: true

  after_save_commit :cache_price


  def as_json(options = {})
    {
      name: coin_name,
      symbol: coin_symbol,
      price: fetch_latest_price
    }
  end

  def fetch_latest_price
    cached_price = Rails.cache.read(price_cache_key)
    if cached_price
      return cached_price
    end
    self.latest_price
  end

  def cache_price
    Rails.cache.write(price_cache_key, self.latest_price, expires_in: 2.minutes)
  end

  def price_cache_key
    "price:#{coin_symbol}"
  end
end

class FetchCoinPriceJob < ApplicationJob
  queue_as :price_queue
  sidekiq_options retry: 0, backtrace: true

  def perform(args)
    action = args["action"] || ""
    @price = args["price_id"].present? ? Price.find(args["price_id"]) : nil
    if action.present?
      self.send(action)
    else
      raise "Action is not defined"
    end
  end


  def queue_price_fetch
    if Price.any?
      Price.order("last_price_fetch_at DESC").each do |price|
        FetchCoinPriceJob.set(queue: :price_queue).perform_later({
          action: "fetch_price_and_cache",
          price_id: price.id
        }.as_json)
      end
    end
  end

  def fetch_price_and_cache
    price_data = CoinGeckoService.fetch_coin_price(@price.coin_symbol)
    if price_data.present?
      @price.update!(latest_price: price_data, last_price_fetch_at: Time.zone.now)
    end
  end
end

class AddCoinsJob < ApplicationJob
  queue_as :coin_queue
  sidekiq_options backtrace: true

  def perform(args)
    action = args[:action] || ""
    @coin_data = args[:coin] || {}
    if action.present?
      self.send(action)
    else
      raise "Action is not defined"
    end
  end

  def fetch_coins
    coins_data = CoinGeckoService.fetch_coins_data
    if coins_data.present?
      coins_data.each do |coin|
        AddCoinsJob.set(queue: :coin_queue_1).perform_later({
          action: "save_coin_data",
          coin: coin
        })
      end
    else
      AddCoinsJob.set(wait: 1.minutes, queue: :coin_queue).perform_later({
        action: "fetch_coins"
      })
    end
  end

  def save_coin_data
    Price.find_or_create_by(coin_symbol: @coin_data["symbol"]) do |coin|
      coin.coin_name = @coin_data["name"]
    end
  rescue => e
    raise "Error saving coin data: #{e.message}"
  end
end

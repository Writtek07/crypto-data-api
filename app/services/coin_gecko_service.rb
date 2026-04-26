class CoinGeckoService
  BASE_URL = "https://api.coingecko.com/api/v3/".freeze
  HEADERS = { "Accept" => "application/json", "x-cg-demo-api-key" => ENV["COINGECKO_API_KEY"] }.freeze

  class << self
    # https://api.coingecko.com/api/v3/coins/list
    def fetch_coins_data
      external_api_service = ExternalApiService.new(url: BASE_URL + "coins/list", method: "GET", headers: HEADERS)
      response = external_api_service.call
      if response[:status] == "success"
        response[:data]
      else
        []
      end
    end

    # https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&symbols=01&precision=10
    def fetch_coin_price(symbol)
      url = BASE_URL + "coins/markets?vs_currency=inr&symbols=" + symbol + "&precision=10"
      external_api_service = ExternalApiService.new(url: url, method: "GET", headers: HEADERS)
      response = external_api_service.call
      if response[:status] == "success"
        response[:data][0]["current_price"]
      else
        nil
      end
    end
  end
end

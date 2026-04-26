class PricesController < ApplicationController
  def index
    @prices = Price.all
    if @prices.present?
      render json: @prices
    else
      AddCoinsJob.set(queue: :coin_queue).perform_later({
        action: "fetch_coins"
      })
      render json: { error: "No coins found at this moment. Please try after some time" }, status: :not_found
    end
  end

  def show
    price = Price.find_by(coin_symbol: params[:id])
    if price.present?
      render json: price, status: :ok
    else
      render json: { error: "Price not found" }, status: :not_found
    end
  end
end

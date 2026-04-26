require "rest-client"

class ExternalApiService
  def initialize(url: "", method: "GET", headers: {}, payload: nil)
    @url = url
    @method = method
    @headers = headers
    @payload = payload
  end

  def call
    begin
      { status: "success", data: JSON.parse(self.execute_call.body) }
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "API Error: #{e.response}"
      { status: "failed", message: e.response }
    rescue => e
      Rails.logger.error "Unexpected error: #{e.message}"
      { status: "failed", message: e.message }
    end
  end

  def execute_call
    RestClient::Request.execute(method: @method.to_sym, url: @url, headers: @headers, payload: @payload, timeout: 60, verify_ssl: Rails.env.production?)
  end
end

require "test_helper"

class ExternalApiServiceTest < ActiveSupport::TestCase
  test "call returns success on 200 response" do
    url = "https://api.example.com/data"
    stub_request(:get, url).to_return(status: 200, body: '{"key": "value"}', headers: {})

    service = ExternalApiService.new(url: url)
    result = service.call

    assert_equal "success", result[:status]
    assert_equal "value", result[:data]["key"]
  end

  test "call returns failed on 404 response" do
    url = "https://api.example.com/not_found"
    stub_request(:get, url).to_return(status: 404, body: "Not Found", headers: {})

    service = ExternalApiService.new(url: url)
    result = service.call

    assert_equal "failed", result[:status]
    assert_not_nil result[:message]
  end

  test "call returns failed on unexpected error" do
    url = "https://api.example.com/error"
    stub_request(:get, url).to_raise(StandardError.new("Network Error"))

    service = ExternalApiService.new(url: url)
    result = service.call

    assert_equal "failed", result[:status]
    assert_equal "Network Error", result[:message]
  end
end

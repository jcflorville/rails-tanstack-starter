require "rails_helper"

RSpec.describe "Rack::Attack throttling", type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.reset!
  end

  after do
    Rack::Attack.enabled = false
    Rack::Attack.reset!
  end

  describe "POST /api/v1/session" do
    let(:credentials) { { email_address: "alice@example.com", password: "wrong" } }

    it "throttles after 10 requests per minute from the same IP" do
      10.times do
        post "/api/v1/session", params: credentials, as: :json
        expect(response).not_to have_http_status(:too_many_requests)
      end

      post "/api/v1/session", params: credentials, as: :json

      expect(response).to have_http_status(:too_many_requests)
      expect(response.parsed_body["error"]).to be_present
      expect(response.headers["Retry-After"]).to be_present
    end

    it "does not throttle requests from a different IP" do
      10.times do
        post "/api/v1/session",
          params: credentials,
          headers: { "REMOTE_ADDR" => "1.2.3.4" },
          as: :json
      end

      post "/api/v1/session",
        params: credentials,
        headers: { "REMOTE_ADDR" => "5.6.7.8" },
        as: :json

      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  describe "POST /api/v1/passwords" do
    it "throttles after 5 requests per hour from the same IP" do
      5.times do
        post "/api/v1/passwords", params: { email_address: "alice@example.com" }, as: :json
        expect(response).not_to have_http_status(:too_many_requests)
      end

      post "/api/v1/passwords", params: { email_address: "alice@example.com" }, as: :json

      expect(response).to have_http_status(:too_many_requests)
      expect(response.parsed_body["error"]).to be_present
    end
  end
end

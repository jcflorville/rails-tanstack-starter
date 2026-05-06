require "rails_helper"

RSpec.describe "Api::V1::Me", type: :request do
  describe "GET /api/v1/me" do
    context "when authenticated" do
      it "returns the current user" do
        user = create(:user, password: "password123")
        post "/api/v1/session", params: { email_address: user.email_address, password: "password123" }, as: :json

        get "/api/v1/me"

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["email_address"]).to eq(user.email_address)
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/me"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/session" do
    let!(:user) { create(:user, email_address: "alice@example.com", password: "password123") }

    context "with valid credentials" do
      it "creates a session and returns the user" do
        post "/api/v1/session",
          params: { email_address: "alice@example.com", password: "password123" },
          as: :json

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["email_address"]).to eq("alice@example.com")
        expect(response.cookies["session_id"]).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns 401 unauthorized" do
        post "/api/v1/session",
          params: { email_address: "alice@example.com", password: "wrong" },
          as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to be_present
      end
    end
  end

  describe "DELETE /api/v1/session" do
    it "destroys the session" do
      user = create(:user, password: "password123")
      post "/api/v1/session", params: { email_address: user.email_address, password: "password123" }, as: :json

      delete "/api/v1/session"

      expect(response).to have_http_status(:no_content)
    end
  end
end

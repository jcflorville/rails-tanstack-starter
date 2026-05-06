require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    context "with valid params" do
      it "creates a user and returns 201 with the user payload" do
        post "/api/v1/users",
          params: { email_address: "new@example.com", password: "password123", password_confirmation: "password123" },
          as: :json

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["email_address"]).to eq("new@example.com")
        expect(response.parsed_body["id"]).to be_present
      end

      it "starts a session and sets the session cookie" do
        post "/api/v1/users",
          params: { email_address: "new@example.com", password: "password123", password_confirmation: "password123" },
          as: :json

        expect(response.cookies["session_id"]).to be_present
      end
    end

    context "with a duplicate email" do
      let!(:existing) { create(:user, email_address: "taken@example.com") }

      it "returns 422 with errors" do
        post "/api/v1/users",
          params: { email_address: "taken@example.com", password: "password123", password_confirmation: "password123" },
          as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end
    end

    context "with missing password" do
      it "returns 422 with errors" do
        post "/api/v1/users",
          params: { email_address: "new@example.com", password: "", password_confirmation: "" },
          as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end
end

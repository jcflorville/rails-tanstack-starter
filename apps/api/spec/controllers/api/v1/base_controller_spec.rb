require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(described_class) do
    allow_unauthenticated_access

    def trigger_not_found
      raise ActiveRecord::RecordNotFound, "Couldn't find Record"
    end

    def trigger_parameter_missing
      raise ActionController::ParameterMissing, :email_address
    end

    def trigger_record_invalid
      user = User.new
      user.save!
    end
  end

  before do
    routes.draw do
      get "trigger_not_found"      => "api/v1/base#trigger_not_found"
      get "trigger_parameter_missing" => "api/v1/base#trigger_parameter_missing"
      get "trigger_record_invalid" => "api/v1/base#trigger_record_invalid"
    end
  end

  describe "rescue_from ActiveRecord::RecordNotFound" do
    it "renders 404 with an error message" do
      get :trigger_not_found

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to be_present
    end
  end

  describe "rescue_from ActionController::ParameterMissing" do
    it "renders 400 with an error message" do
      get :trigger_parameter_missing

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to be_present
    end
  end

  describe "rescue_from ActiveRecord::RecordInvalid" do
    it "renders 422 with validation errors" do
      get :trigger_record_invalid

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end
end

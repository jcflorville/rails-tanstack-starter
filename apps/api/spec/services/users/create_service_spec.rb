require "rails_helper"

RSpec.describe Users::CreateService do
  describe "#call" do
    context "with valid params" do
      it "creates the user and returns a success result" do
        result = described_class.new(params: { email_address: "new@example.com", password: "password123" }).call

        expect(result).to be_success
        expect(result.data).to be_persisted
        expect(result.data.email_address).to eq("new@example.com")
      end
    end

    context "with invalid params" do
      it "returns a failure result with errors" do
        result = described_class.new(params: { email_address: nil, password: "password123" }).call

        expect(result).to be_failure
        expect(result.errors).to be_present
      end
    end
  end
end

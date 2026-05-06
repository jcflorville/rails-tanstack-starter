require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:user)).to be_valid
    end

    it "requires a unique email_address" do
      create(:user, email_address: "taken@example.com")
      duplicate = build(:user, email_address: "taken@example.com")

      expect(duplicate).not_to be_valid
    end

    it "normalizes email_address" do
      user = create(:user, email_address: "  Mixed@Example.COM  ")

      expect(user.email_address).to eq("mixed@example.com")
    end
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      user = create(:user, password: "secret123")

      expect(User.authenticate_by(email_address: user.email_address, password: "secret123")).to eq(user)
    end

    it "does not authenticate with the wrong password" do
      user = create(:user, password: "secret123")

      expect(User.authenticate_by(email_address: user.email_address, password: "wrong")).to be_nil
    end
  end
end

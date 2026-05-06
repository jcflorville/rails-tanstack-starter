module Api
  module V1
    class PasswordsController < BaseController
      allow_unauthenticated_access
      before_action :set_user_by_token, only: %i[update]
      rate_limit to: 10, within: 3.minutes, only: :create

      def create
        user = User.find_by(email_address: params[:email_address])
        PasswordsMailer.reset(user).deliver_later if user

        head :accepted
      end

      def update
        if @user.update(params.permit(:password, :password_confirmation))
          @user.sessions.destroy_all
          head :no_content
        else
          render json: { errors: @user.errors }, status: :unprocessable_entity
        end
      end

      private
        def set_user_by_token
          @user = User.find_by_password_reset_token!(params[:token])
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          render json: { error: "Invalid or expired reset token" }, status: :unprocessable_entity
        end
    end
  end
end

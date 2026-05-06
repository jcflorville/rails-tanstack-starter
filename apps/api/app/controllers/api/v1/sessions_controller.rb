module Api
  module V1
    class SessionsController < BaseController
      allow_unauthenticated_access only: %i[create]
      rate_limit to: 10, within: 3.minutes, only: :create

      def create
        user = User.authenticate_by(params.permit(:email_address, :password))

        if user
          start_new_session_for(user)
          render json: UserSerializer.render(user), status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        terminate_session
        head :no_content
      end
    end
  end
end

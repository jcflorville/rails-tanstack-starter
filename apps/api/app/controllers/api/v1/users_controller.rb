module Api
  module V1
    class UsersController < BaseController
      allow_unauthenticated_access only: %i[create]

      def create
        result = Users::CreateService.new(params: user_params).call

        if result.success?
          start_new_session_for(result.data)
          render json: UserSerializer.render(result.data), status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

        def user_params
          params.permit(:email_address, :password, :password_confirmation)
        end
    end
  end
end

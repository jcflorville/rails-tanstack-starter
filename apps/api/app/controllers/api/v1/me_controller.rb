module Api
  module V1
    class MeController < BaseController
      def show
        render json: UserSerializer.render(Current.user)
      end
    end
  end
end

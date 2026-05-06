module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound,       with: :not_found
      rescue_from ActionController::ParameterMissing, with: :bad_request
      rescue_from ActiveRecord::RecordInvalid,        with: :unprocessable

      private

        def not_found(e)
          render json: { error: e.message }, status: :not_found
        end

        def bad_request(e)
          render json: { error: e.message }, status: :bad_request
        end

        def unprocessable(e)
          render json: { errors: e.record.errors }, status: :unprocessable_content
        end
    end
  end
end

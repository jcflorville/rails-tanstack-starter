module Users
  class CreateService
    def initialize(params:)
      @params = params
    end

    def call
      user = User.new(@params)

      if user.save
        ServiceResult.success(user)
      else
        ServiceResult.failure(user.errors)
      end
    end
  end
end

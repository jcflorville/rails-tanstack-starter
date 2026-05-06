class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @token = user.password_reset_token
    @reset_url = "#{ENV.fetch('WEB_ORIGIN', 'http://localhost:5173')}/reset-password?token=#{@token}"
    mail subject: "Reset your password", to: user.email_address
  end
end

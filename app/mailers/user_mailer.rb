class UserMailer < ApplicationMailer
  def email_change_confirmation(email_address:, token:, user:)
    @token = token
    @user = user
    mail to: email_address, subject: I18n.t("user_mailer.email_change_confirmation.subject")
  end
end

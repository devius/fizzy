class AccountMailer < ApplicationMailer
  def cancellation(cancellation)
    @account = cancellation.account
    @user = cancellation.initiated_by

    mail(
      to: @user.identity.email_address,
      subject: I18n.t("mailers.account_mailer.cancellation.subject")
    )
  end
end

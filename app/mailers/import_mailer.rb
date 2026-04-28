class ImportMailer < ApplicationMailer
  def completed(identity, account)
    @account = account
    mail to: identity.email_address, subject: I18n.t("mailers.import_mailer.completed.subject")
  end

  def failed(import)
    @import = import
    mail to: import.identity.email_address, subject: I18n.t("mailers.import_mailer.failed.subject")
  end
end

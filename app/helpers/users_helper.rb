module UsersHelper
  def role_display_name(user)
    case user.role
    when "admin" then I18n.t("helpers.users.role.admin")
    else user.role.titleize
    end
  end
end

module JavascriptTranslationsHelper
  def javascript_translations_tag
    tag.script id: "js-i18n", type: "application/json" do
      I18n.t("javascript").to_json.html_safe
    end
  end
end

module WebhooksHelper
  ACTION_KEYS = %i[
    card_published card_title_changed card_board_changed comment_created
    card_assigned card_unassigned card_triaged card_closed card_reopened
    card_postponed card_auto_postponed card_sent_back_to_triage
  ].freeze

  def webhook_action_options(actions = Webhook::PERMITTED_ACTIONS)
    ACTION_KEYS.each_with_object({}) do |key, options|
      options[key] = I18n.t("helpers.webhooks.actions.#{key}") if actions.include?(key.to_s)
    end
  end

  def webhook_action_label(action)
    if ACTION_KEYS.include?(action.to_sym)
      I18n.t("helpers.webhooks.actions.#{action}")
    else
      action.to_s.humanize
    end
  end

  def link_to_webhooks(board, &)
    label = I18n.t("helpers.webhooks.label")
    link_to board_webhooks_path(board_id: board),
        class: [ "btn btn--circle-mobile", { "btn--reversed": board.webhooks.any? } ],
        data: { controller: "tooltip", bridge__overflow_menu_target: "item", bridge_title: label } do
      icon_tag("world") + tag.span(label, class: "for-screen-reader")
    end
  end
end

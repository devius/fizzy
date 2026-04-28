module BridgeHelper
  def bridge_icon(name)
    asset_url("#{name}.svg")
  end

  def bridged_button_to_board(board)
    label = I18n.t("helpers.bridge.go_to", name: board.name)
    link_to label, board, hidden: true, data: {
      bridge__buttons_target: "button",
      bridge_icon_url: bridge_icon("board"),
      bridge_title: label
    }
  end

  def bridged_share_url_button(description = nil)
    label = I18n.t("helpers.bridge.share")
    tag.button label, hidden: true, data: {
      controller: "bridge--share",
      action: "bridge--share#shareUrl",
      bridge__overflow_menu_target: "item",
      bridge_title: label,
      bridge_share_description: description
    }
  end

  def bridge_share_card_description(card)
    date_added = card.created_at.strftime("%b %e")
    date_updated = card.last_active_at.strftime("%b %e")
    author = card.creator.familiar_name
    assignment_state = card.assignees.any? ?
      I18n.t("helpers.bridge.assigned_to", names: card.assignees.map { |assignee| h assignee.familiar_name }.to_sentence) :
      I18n.t("helpers.bridge.not_assigned")
    I18n.t("helpers.bridge.card_share_description", added: date_added, author: author, assignment_state: assignment_state, updated: date_updated)
  end

  def bridge_share_board_description(board)
    I18n.t("helpers.bridge.board_share_description", open: board.cards.active.count, in_stream: board.cards.awaiting_triage.count)
  end
end

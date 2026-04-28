module BoardsHelper
  def link_back_to_board(board, prefer_referrer: [])
    back_link_to board.name, board, "keydown.left@document->hotkey#click keydown.esc@document->hotkey#click click->turbo-navigation#backIfSamePath", prefer_referrer:
  end

  def link_to_edit_board(board)
    link_to edit_board_path(board), class: "btn btn--circle-mobile",
      data: { controller: "tooltip", bridge__overflow_menu_target: "item", bridge_title: I18n.t("helpers.boards.settings") } do
      icon_tag("settings") + tag.span(I18n.t("helpers.boards.settings_for", name: board.name), class: "for-screen-reader")
    end
  end
end

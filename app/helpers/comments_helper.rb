module CommentsHelper
  def new_comment_placeholder(card)
    if card.creator == Current.user && card.comments.empty?
      I18n.t("helpers.comments.first_comment_placeholder")
    else
      I18n.t("helpers.comments.placeholder")
    end
  end
end

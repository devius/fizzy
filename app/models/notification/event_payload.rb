class Notification::EventPayload < Notification::DefaultPayload
  include ExcerptHelper

  def title
    case event.action
    when "comment_created"
      I18n.t("helpers.notifications.re_prefix", title: card_title)
    else
      card_title
    end
  end

  def body
    case event.action
    when "comment_created"
      format_excerpt(event.eventable.body, length: 200)
    when "card_assigned"
      t_body("assigned")
    when "card_published"
      t_body("added")
    when "card_closed"
      card.closure ? t_body("moved_to_done") : t_body("closed")
    when "card_reopened"
      t_body("reopened")
    when "card_triaged"
      column_name.present? ? t_body("moved_to_column", column: column_name) : t_body("moved")
    when "card_sent_back_to_triage"
      t_body("sent_back_to_triage")
    when "card_board_changed", "card_collection_changed"
      new_location_name.present? ? t_body("moved_to_location", location: new_location_name) : t_body("moved")
    when "card_title_changed"
      new_title.present? ? t_body("renamed_to", new_title: new_title) : t_body("renamed")
    when "card_postponed"
      t_body("postponed")
    when "card_auto_postponed"
      I18n.t("notifications.event_payload.body.auto_postponed")
    else
      t_body("updated")
    end
  end

  def url
    case event.action
    when "comment_created"
      card_url_with_comment_anchor(event.eventable)
    else
      card_url(card)
    end
  end

  def category
    case event.action
    when "card_assigned" then "assignment"
    when "comment_created" then "comment"
    else "card"
    end
  end

  def high_priority?
    event.action.card_assigned?
  end

  private
    def event
      notification.source
    end

    def card_title
      card.title.presence || I18n.t("helpers.notifications.card_number", number: card.number)
    end

    def t_body(key, **vars)
      I18n.t("notifications.event_payload.body.#{key}", creator: event.creator.name, **vars)
    end

    def event_particulars
      event.particulars.dig("particulars") || {}
    end

    def column_name
      event_particulars["column"]
    end

    def new_location_name
      event_particulars["new_board"] || event_particulars["new_collection"]
    end

    def new_title
      event_particulars["new_title"]
    end

    def card_url_with_comment_anchor(comment)
      Rails.application.routes.url_helpers.card_url(
        comment.card,
        anchor: ActionView::RecordIdentifier.dom_id(comment),
        **url_options
      )
    end
end

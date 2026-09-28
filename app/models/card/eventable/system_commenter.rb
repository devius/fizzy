class Card::Eventable::SystemCommenter
  include ERB::Util

  attr_reader :card, :event

  def initialize(card, event)
    @card, @event = card, event
  end

  def comment
    return unless comment_body.present?

    card.comments.create! creator: card.account.system_user, body: comment_body, created_at: event.created_at
  end

  private
    def comment_body
      case event.action
      when "card_assigned"
        body_for :assigned, creator: creator_name, names: assignee_names
      when "card_unassigned"
        body_for :unassigned, creator: creator_name, names: assignee_names
      when "card_closed"
        body_for :closed, creator: creator_name
      when "card_reopened"
        body_for :reopened, creator: creator_name
      when "card_postponed"
        body_for :postponed, creator: creator_name
      when "card_auto_postponed"
        body_for :auto_postponed
      when "card_title_changed"
        body_for :title_changed, creator: creator_name, old_title: old_title, new_title: new_title
      when "card_board_changed"
        body_for :board_changed, creator: creator_name, old_board: old_board, new_board: new_board
      when "card_triaged"
        body_for :triaged, creator: creator_name, column: column
      when "card_sent_back_to_triage"
        body_for :sent_back_to_triage, creator: creator_name
      end
    end

    def body_for(key, **values)
      I18n.t("events.system_comments.#{key}_html", **values)
    end

    def creator_name
      h event.creator.name
    end

    def assignee_names
      h event.assignees.pluck(:name).to_sentence
    end

    def old_title
      h event.particulars.dig("particulars", "old_title")
    end

    def new_title
      h event.particulars.dig("particulars", "new_title")
    end

    def old_board
      h event.particulars.dig("particulars", "old_board")
    end

    def new_board
      h event.particulars.dig("particulars", "new_board")
    end

    def column
      h event.particulars.dig("particulars", "column")
    end
end

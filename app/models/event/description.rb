class Event::Description
  include ActionView::Helpers::TagHelper
  include ERB::Util

  attr_reader :event, :user

  def initialize(event, user)
    @event = event
    @user = user
  end

  def to_html
    to_sentence(creator_tag, card_title_tag).html_safe
  end

  def to_plain_text
    to_sentence(creator_name, quoted(card.title)).html_safe
  end

  private
    def to_sentence(creator, card_title)
      if event.action.comment_created?
        comment_sentence(creator, card_title)
      else
        action_sentence(creator, card_title)
      end
    end

    def creator_tag
      tag.span data: { creator_id: event.creator.id } do
        tag.span(I18n.t("events.description.you"), data: { only_visible_to_you: true }) +
        tag.span(I18n.t("events.description.creator", name: event.creator.name), data: { only_visible_to_others: true })
      end
    end

    def card_title_tag
      tag.span card.title, class: "txt-underline"
    end

    def creator_name
      h I18n.t("events.description.creator", name: event.creator.name)
    end

    def quoted(text)
      h I18n.t("events.description.quoted", text: text)
    end

    def card
      @card ||= event.action.comment_created? ? event.eventable.card : event.eventable
    end

    def comment_sentence(creator, card_title)
      sentence(:commented, creator, card_title)
    end

    def action_sentence(creator, card_title)
      case event.action
      when "card_assigned"
        assigned_sentence(creator, card_title)
      when "card_unassigned"
        unassigned_sentence(creator, card_title)
      when "card_published"
        sentence(:published, creator, card_title)
      when "card_closed"
        sentence(:closed, creator, card_title)
      when "card_reopened"
        sentence(:reopened, creator, card_title)
      when "card_postponed"
        sentence(:postponed, creator, card_title)
      when "card_auto_postponed"
        sentence(:auto_postponed, creator, card_title)
      when "card_resumed"
        sentence(:resumed, creator, card_title)
      when "card_title_changed"
        renamed_sentence(creator, card_title)
      when "card_board_changed", "card_collection_changed"
        moved_sentence(creator, card_title)
      when "card_triaged"
        triaged_sentence(creator, card_title)
      when "card_sent_back_to_triage"
        sentence(:sent_back_to_triage, creator, card_title)
      end
    end

    def sentence(key, creator, card_title, **values)
      I18n.t("events.description.#{key}", creator: creator, card: card_title, **values)
    end

    def assigned_sentence(creator, card_title)
      if event.assignees.include?(user)
        sentence(:will_handle, creator, card_title)
      else
        sentence(:assigned, creator, card_title, names: assignee_names)
      end
    end

    def unassigned_sentence(creator, card_title)
      sentence(:unassigned, creator, card_title, names: unassigned_names)
    end

    def renamed_sentence(creator, card_title)
      sentence(:renamed, creator, card_title, old_title: old_title)
    end

    def moved_sentence(creator, card_title)
      sentence(:moved, creator, card_title, location: new_location)
    end

    def triaged_sentence(creator, card_title)
      sentence(:triaged, creator, card_title, column: column)
    end

    def assignee_names
      h event.assignees.pluck(:name).to_sentence
    end

    def unassigned_names
      h(event.assignees.include?(user) ? I18n.t("events.description.yourself") : assignee_names)
    end

    def old_title
      h event.particulars.dig("particulars", "old_title")
    end

    def new_location
      h(event.particulars.dig("particulars", "new_board") || event.particulars.dig("particulars", "new_collection"))
    end

    def column
      h event.particulars.dig("particulars", "column")
    end
end

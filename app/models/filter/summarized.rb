module Filter::Summarized
  def summary
    [ index_summary, sort_summary, tag_summary, assignee_summary, creator_summary, terms_summary ].compact.to_sentence
  end

  private
    def index_summary
      unless indexed_by.all?
        I18n.t("filters.summary.indexes.#{indexed_by}", default: indexed_by.humanize)
      end
    end

    def sort_summary
      unless sorted_by.latest?
        I18n.t("filters.summary.sorts.#{sorted_by}", default: sorted_by.humanize)
      end
    end

    def tag_summary
      if tags.any?
        "#{tags.map(&:hashtag).to_choice_sentence}"
      end
    end

    def assignee_summary
      if assignees.any?
        I18n.t("filters.summary.assigned_to", names: assignees.pluck(:name).to_choice_sentence)
      elsif assignment_status.unassigned?
        I18n.t("filters.summary.assigned_to_no_one")
      end
    end

    def terms_summary
      if terms.any?
        I18n.t("filters.summary.matching", terms: terms.map { |term| I18n.t("filters.summary.quoted_term", term: term) }.to_sentence)
      end
    end

    def creator_summary
      if creators.any?
        I18n.t("filters.summary.added_by", names: creators.pluck(:name).to_choice_sentence)
      end
    end
end

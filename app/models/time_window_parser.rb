class TimeWindowParser
  attr_reader :now

  VALUES = %w[ today yesterday thisweek thismonth thisyear lastweek lastmonth lastyear ]

  class << self
    def parse(string)
      new.parse(string)
    end

    def human_name_for(value)
      I18n.t("filters.time_windows.#{value}") if value.in?(VALUES)
    end
  end

  def initialize(now: Time.current)
    @now = now
  end

  def parse(string)
    case normalize(string)
    when "today"
      now.all_day
    when "yesterday"
      (now - 1.day).all_day
    when "thisweek"
      now.all_week
    when "thismonth"
      now.all_month
    when "thisyear"
      now.all_year
    when "lastweek"
      (now - 1.week).all_week
    when "lastmonth"
      (now - 1.month).all_month
    when "lastyear"
      (now - 1.year).all_year
    end
  end

  private
    def normalize(string)
      if string
        string.downcase.gsub(/[\s_\-]/, "")
      end
    end
end

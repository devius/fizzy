class Account::Seeder
  # Created in this order, so the last card ("rename") shows up first. Copy lives in account.seeder.cards.
  # TODO: Replace the passkey video with a screencap of creating a passkey
  ONBOARDING_CARDS = {
    orientation: "videos/fizzyorientation-4k.mp4",
    passkey: "videos/creating_a_passkey.mp4",
    invite_link: "images/invite-link.gif",
    home: "images/back-to-home.gif",
    assigned: "images/all-assigned.gif",
    menu: "images/open-menu.gif",
    assign: "images/assign-to-self.gif",
    tag: "images/tag-design.gif",
    columns: "images/make-columns.gif",
    not_now: "images/not-now.gif",
    rename: "images/rename.gif"
  }

  attr_reader :account, :creator

  def initialize(account, creator)
    @account = account
    @creator = creator
  end

  def seed
    Current.set(user: creator, account: account) do
      populate
    end
  end

  def seed!
    raise "You can't run in production environments" unless Rails.env.local?

    delete_everything
    seed
  end

  private
    def populate
      # ---------------
      # Playground Board
      # ---------------
      playground = account.boards.create! name: "Playground", creator: creator, all_access: true
      playground.update! auto_postpone_period: 365.days

      ONBOARDING_CARDS.each do |key, media|
        playground.cards.create! creator: creator, status: "published",
          title: I18n.t("account.seeder.cards.#{key}.title"),
          description: I18n.t("account.seeder.cards.#{key}.body_html") + onboarding_attachment(key, media)
      end
    end

    def onboarding_attachment(key, media)
      alt = I18n.t("account.seeder.cards.#{key}.alt", default: nil)
      caption = I18n.t("account.seeder.cards.#{key}.caption")
      url = "https://videos.37signals.com/fizzy/assets/#{media}"
      video = media.end_with?(".mp4")

      attributes = {
        url: url, alt: alt, caption: caption,
        "content-type": video ? "video/mp4" : "image/*",
        filename: File.basename(media),
        presentation: ("gallery" unless video)
      }.compact.map { |name, value| %(#{name}="#{ERB::Util.html_escape(value)}") }

      "\n<action-text-attachment #{attributes.join(" ")}></action-text-attachment>"
    end

    def delete_everything
      Current.set(user: creator, account: account) do
        account.boards.destroy_all
      end
    end
end

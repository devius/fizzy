module EmojiHelper
  REACTION_KEYS = {
    "👏" => :clapping,
    "👍" => :thumbs_up,
    "🙌" => :hands_raised,
    "💪" => :flexed_bicep,
    "🤘" => :sign_of_the_horns,
    "✊" => :raised_fist,
    "✨" => :sparkles,
    "❤️" => :red_heart,
    "💯" => :hundred_points,
    "🎉" => :party_popper,
    "🤩" => :starry_eyes,
    "🥳" => :partying_face,
    "😊" => :smiling_face_flush,
    "😀" => :grinning_face,
    "😂" => :tears_of_joy,
    "😅" => :grinning_sweat,
    "😎" => :smiling_sunglasses,
    "😉" => :winking_face,
    "😜" => :winking_tongue,
    "😬" => :grimacing_face,
    "😮" => :surprised_face,
    "😳" => :flushed_face,
    "🤔" => :thinking_face,
    "😒" => :unamused_face,
    "😢" => :crying_face,
    "😭" => :loudly_crying_face,
    "😱" => :face_screaming,
    "👀" => :eyes,
    "🙏" => :hands_pressed,
    "💩" => :pile_of_poop,
    "👎" => :thumbs_down,
    "✌️" => :peace,
    "👈" => :finger_left,
    "👆" => :finger_up,
    "✋" => :raised_hand,
    "👋" => :waving_hand,
    "☀️" => :sun,
    "🌙" => :moon,
    "💥" => :collision,
    "🔥" => :fire,
    "🎂" => :birthday_cake,
    "🍴" => :fork_and_knife,
    "💰" => :money_bag,
    "🥇" => :gold_medal,
    "🚨" => :red_flashing_light,
    "💡" => :light_bulb,
    "🛠" => :hammer_and_wrench,
    "📈" => :chart_upward,
    "✅" => :check_mark,
    "📢" => :loudspeaker
  }.freeze

  def reactions
    REACTION_KEYS.each_with_object({}) do |(character, key), hash|
      hash[character] = I18n.t("helpers.emoji.reactions.#{key}")
    end
  end

  def reaction_title(character)
    key = REACTION_KEYS[character]
    key ? I18n.t("helpers.emoji.reactions.#{key}") : nil
  end
end

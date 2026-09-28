module ChoiceSentenceArrayConversion
  def to_choice_sentence
    to_sentence two_words_connector: I18n.t("support.choice_array.two_words_connector"), last_word_connector: I18n.t("support.choice_array.last_word_connector")
  end
end

Array.include ChoiceSentenceArrayConversion

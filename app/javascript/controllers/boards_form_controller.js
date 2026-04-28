import { Controller } from "@hotwired/stimulus"
import { nextEventLoopTick } from "helpers/timing_helpers";
import { t } from "lib/i18n"

export default class extends Controller {
  static targets = ["meCheckbox"]
  static values = { selfRemovalPromptMessage: { type: String, default: "" } }

  async submitWithWarning(event) {
    if (this.hasMeCheckboxTarget && !this.meCheckboxTarget.checked && !this.confirmed) {
      event.detail.formSubmission.stop()

      const message = this.selfRemovalPromptMessageValue || t("forms.are_you_sure")

      if (confirm(message)) {
        await nextEventLoopTick()
        this.confirmed = true
        this.element.requestSubmit()
      }
    }
  }
}

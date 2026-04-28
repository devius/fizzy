import { Controller } from "@hotwired/stimulus"
import { differenceInDays, secondsToDate } from "helpers/date_helpers"
import { t } from "lib/i18n"

const DEFAULT_LOCALE = "en-US"

export default class extends Controller {
  static targets = [ "time", "date", "datetime", "shortdate", "ago", "indays", "daysago", "agoorweekday", "timeordate" ]
  static values = { refreshInterval: Number }
  static classes = [ "local-time-value"]

  #timer

  initialize() {
    this.timeFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { timeStyle: "short" })
    this.dateFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { dateStyle: "long" })
    this.shortdateFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { month: "short", day: "numeric" })
    this.datetimeFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { timeStyle: "short", dateStyle: "short" })
    this.agoFormatter = new AgoFormatter()
    this.daysagoFormatter = new DaysAgoFormatter()
    this.datewithweekdayFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { weekday: "long", month: "long", day: "numeric" })
    this.datewithweekdayFormatter = new Intl.DateTimeFormat(DEFAULT_LOCALE, { weekday: "long", month: "long", day: "numeric" })
    this.indaysFormatter = new InDaysFormatter()
    this.agoorweekdayFormatter = new DaysAgoOrWeekdayFormatter()
    this.timeordateFormatter = new TimeOrDateFormatter()
  }

  connect() {
    this.#timer = setInterval(() => this.#refreshRelativeTimes(), 30_000)
  }

  disconnect() {
    clearInterval(this.#timer)
  }

  refreshAll() {
    this.constructor.targets.forEach(targetName => {
      this.targets.findAll(targetName).forEach(target => {
        this.#formatTime(this[`${targetName}Formatter`], target)
      })
    })
  }

  refreshTarget(event) {
    const target = event.target;
    const targetName = target.dataset.localTimeTarget
    this.#formatTime(this[`${targetName}Formatter`], target)
  }

  timeTargetConnected(target) {
    this.#formatTime(this.timeFormatter, target)
  }

  dateTargetConnected(target) {
    this.#formatTime(this.dateFormatter, target)
  }

  datetimeTargetConnected(target) {
    this.#formatTime(this.datetimeFormatter, target)
  }

  shortdateTargetConnected(target) {
    this.#formatTime(this.shortdateFormatter, target)
  }

  agoTargetConnected(target) {
    this.#formatTime(this.agoFormatter, target)
  }

  indaysTargetConnected(target) {
    this.#formatTime(this.indaysFormatter, target)
  }

  daysagoTargetConnected(target) {
    this.#formatTime(this.daysagoFormatter, target)
  }

  agoorweekdayTargetConnected(target) {
    this.#formatTime(this.agoorweekdayFormatter, target)
  }

  timeordateTargetConnected(target) {
    this.#formatTime(this.timeordateFormatter, target)
  }

  #refreshRelativeTimes() {
    this.agoTargets.forEach(target => {
      this.#formatTime(this.agoFormatter, target)
    })
  }

  #formatTime(formatter, target) {
    const dt = secondsToDate(parseInt(target.getAttribute("datetime")))
    target.innerHTML = formatter.format(dt)
    target.title = this.datetimeFormatter.format(dt)
  }
}

class AgoFormatter {
  format(dt) {
    const now = new Date()
    const seconds = (now - dt) / 1000
    const minutes = seconds / 60
    const hours = minutes / 60
    const days = hours / 24
    const weeks = days / 7
    const months = days / (365 / 12)
    const years = days / 365

    if (years >= 1) return this.#translate("x_years_ago", years)
    if (months >= 1) return this.#translate("x_months_ago", months)
    if (weeks >= 1) return this.#translate("x_weeks_ago", weeks)
    if (days >= 1) return this.#translate("x_days_ago", days)
    if (hours >= 1) return this.#translate("x_hours_ago", hours)
    if (minutes >= 1) return this.#translate("x_minutes_ago", minutes)

    return t("local_time.less_than_a_minute_ago")
  }

  #translate(unitKey, quantity) {
    quantity = Math.floor(quantity)
    const form = quantity === 1 ? "one" : "other"
    return t(`local_time.${unitKey}.${form}`, { count: quantity })
  }
}

class DaysAgoFormatter {
  format(date) {
    const days = differenceInDays(date, new Date())

    if (days <= 0) return styleableValue(t("local_time.today"))
    if (days === 1) return styleableValue(t("local_time.yesterday"))
    return t("local_time.x_days_ago_styled", { count: styleableValue(days) })
  }
}

class DaysAgoOrWeekdayFormatter {
  format(date) {
    const days = differenceInDays(date, new Date())

    if (days <= 1) {
      return new DaysAgoFormatter().format(date)
    } else {
      return new Intl.DateTimeFormat(DEFAULT_LOCALE, { weekday: "long", month: "long", day: "numeric" }).format(date)
    }
  }
}

class InDaysFormatter {
  format(date) {
    const days = differenceInDays(new Date(), date)

    if (days <= 0) return styleableValue(t("local_time.today"))
    if (days === 1) return styleableValue(t("local_time.tomorrow"))
    const form = days === 1 ? "one" : "other"
    return t(`local_time.in_x_days.${form}`, { count: styleableValue(days) })
  }
}

class TimeOrDateFormatter {
  format(date) {
    const days = differenceInDays(date, new Date())

    if (days >= 1) {
      return new Intl.DateTimeFormat(DEFAULT_LOCALE, { month: "short", day: "numeric" }).format(date)
    } else {
      return new Intl.DateTimeFormat(DEFAULT_LOCALE, { timeStyle: "short" }).format(date)
    }
  }
}

function styleableValue(value) {
  return `<span class="local-time-value">${value}</span>`
}

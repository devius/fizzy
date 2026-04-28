// Tiny client-side i18n that reads translations from a JSON script tag
// emitted by the Rails layout (see app/views/layouts/shared/_head.html.erb).
//
// Usage:
//   import { t } from "lib/i18n"
//   t("local_time.less_than_a_minute_ago")
//   t("local_time.x_days_ago", { count: 3 })
//
// Missing keys fall back to the key itself so they're easy to spot.

let cache = null

function load() {
  if (cache) return cache
  const node = document.getElementById("js-i18n")
  if (!node) return (cache = {})
  try {
    cache = JSON.parse(node.textContent || "{}")
  } catch (_) {
    cache = {}
  }
  return cache
}

function lookup(key) {
  const dict = load()
  return key.split(".").reduce((acc, part) => (acc != null ? acc[part] : undefined), dict)
}

export function t(key, vars) {
  let value = lookup(key)
  if (typeof value !== "string") return key
  if (vars) {
    for (const name in vars) {
      value = value.replaceAll(`%{${name}}`, vars[name])
    }
  }
  return value
}

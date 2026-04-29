# CLAUDE.md

This file is for Claude Code working on this **fork** of Basecamp's Fizzy. For general Fizzy architecture (multi-tenancy, models, entropy system, jobs, etc.) read `AGENTS.md` first — this file only covers what's *different here*.

## What this fork is

`devius/fizzy`, branch `i18n-georgian`. A Rails i18n layer added on top of upstream so the UI can render in Georgian (`ka`). Default locale is `:ka`, with `:en` fallback — untranslated keys render in English instead of erroring.

The user (native Georgian speaker) self-hosts this on Coolify. Goal is to keep diverging cleanly from upstream and rebase forward over time.

## i18n conventions

### Locale file layout

Translations live in **namespaced files**, one pair per area:

```
config/locales/
  boards.{en,ka}.yml         users.{en,ka}.yml
  cards.{en,ka}.yml          account.{en,ka}.yml
  notifications.{en,ka}.yml  sessions.{en,ka}.yml
  filters.{en,ka}.yml        signups.{en,ka}.yml
  events.{en,ka}.yml         public.{en,ka}.yml
  mailers.{en,ka}.yml        misc.{en,ka}.yml
  helpers.{en,ka}.yml        flashes.{en,ka}.yml
  javascript.{en,ka}.yml
  en.yml ka.yml              # original Rails-generated; layouts + my/menu only
```

**When adding new strings:** put them in the namespaced file that matches the area, not `en.yml`/`ka.yml`. Mirror the key tree across both `en` and `ka` files — agents that translated this verified key parity, please don't break it.

### How strings are looked up

| Where | API | Example |
|---|---|---|
| ERB views | Lazy lookup `t(".key")` | In `app/views/boards/show.html.erb` → resolves `boards.show.key` |
| Helpers | Full path `I18n.t("...")` | `I18n.t("helpers.cards.added_by", name: ...)` |
| Controllers (flash messages) | Full path | `notice: I18n.t("flashes.saved")` |
| Mailers | Lazy in views, full path in subjects | `mail(subject: I18n.t("mailers.user_mailer.x.subject"))` |
| JS (Stimulus) | `import { t } from "lib/i18n"` | `t("local_time.x_days_ago.other", { count })` |

### JS i18n plumbing

JavaScript can't reach Rails `I18n` directly, so:

- `app/helpers/javascript_translations_helper.rb` emits a `<script id="js-i18n" type="application/json">…</script>` tag containing the entire `javascript:` subtree of the active locale.
- `app/views/layouts/shared/_head.html.erb` calls `<%= javascript_translations_tag %>`.
- `app/javascript/lib/i18n.js` reads that JSON and exposes `t(key, vars)` with `%{var}` interpolation.
- New JS-side strings → add under `javascript:` namespace in `javascript.en.yml` + `javascript.ka.yml` and `import { t } from "lib/i18n"` in the controller.
- Pluralization uses `.one`/`.other` keys; pass `{ count: n }` and pick the form in the controller (`count === 1 ? "one" : "other"`). Georgian doesn't really inflect plurals on time-units, so both forms are usually identical text.

### What NOT to translate

- Brand names: **Fizzy, Basecamp, 37signals, HEY, Playground**.
- CSS classes, ids, `data-*` programmatic values, hrefs, icon names, Stimulus controller/action strings, HTTP headers, JS event codes (`"Digit5"`, `"Escape"` etc.).
- OS/browser UI labels referenced inside install/permission instructions (e.g. "System Settings…") — those refer to actual system UI users must locate visually.

### Soft spots — known translation issues to flag

Georgian uses agglutinative case suffixes that vary by the ending vowel of the noun. Interpolated names (e.g. `%{creator}-მა`) won't always read perfectly. Specific spots flagged for native review:

- `helpers.ka.yml` — notification verb-phrase templates with creator names.
- `boards.ka.yml` — "ყველას" vs "ყველა" for "Everyone".
- `notifications.ka.yml` — `mentioned_you` verb form.
- `cards.ka.yml` / `reactions` — `-მა` ergative suffix on names.

If the user reports a wording issue in any of these, prefer adjusting the YAML rather than rewriting the surrounding code.

## Deploy pipeline

```
git push origin i18n-georgian
        ↓
GitHub Actions (.github/workflows/publish-image.yml)
  builds linux/amd64 + linux/arm64 (~5 min)
        ↓
ghcr.io/devius/fizzy:i18n-georgian   ← public package
        ↓
deploy job → Coolify webhook (ordunet.ge)
        ↓
Coolify pulls, restarts service
```

Workflow triggers on pushes to `main` *and* `i18n-georgian` (we added the branch to the trigger list). Manual dispatch: `gh workflow run publish-image.yml --repo devius/fizzy --ref i18n-georgian`.

The final `deploy` job hits `https://coolify.ordunet.ge/api/v1/deploy?uuid=…&force=false` with a bearer token from the `COOLIFY_DEPLOY_TOKEN` GH Actions secret (rotate via `gh secret set COOLIFY_DEPLOY_TOKEN --repo devius/fizzy`). It only runs on the `i18n-georgian` branch.

The Coolify compose for this fork only differs from upstream in the `image:` line:

```yaml
image: 'ghcr.io/devius/fizzy:i18n-georgian'   # was ghcr.io/basecamp/fizzy:main
```

## Working with upstream

- `origin` → `devius/fizzy`
- `upstream` → `basecamp/fizzy`

Pull upstream changes with `git fetch upstream && git rebase upstream/main` on the `i18n-georgian` branch. New views from upstream will arrive untranslated; English fallback keeps them working until they get `t()` calls.

When upstream renames a key/file we use, the lazy lookup path changes — search for the old path in `config/locales/*.yml` and rename to match.

## When to use AGENTS.md vs this file

- **`AGENTS.md`** — Upstream Fizzy domain (multi-tenancy URL slugs, entropy auto-postpone, Solid Queue, sharded search, deploy via Kamal, etc.). Read first.
- **This file** — Anything specific to the i18n layer or this fork's deploy.

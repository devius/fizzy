# CLAUDE.md

This file is for Claude Code working on this **fork** of Basecamp's Fizzy. For general Fizzy architecture (multi-tenancy, models, entropy system, jobs, etc.) read `AGENTS.md` first — this file only covers what's *different here*.

## What this fork is

`devius/fizzy`, branch `i18n-georgian`. A Rails i18n layer added on top of upstream so the UI can render in Georgian (`ka`). Default locale is `:ka`, with `:en` fallback — untranslated keys render in English instead of erroring.

The fallback is set in `config/application.rb` (`config.i18n.fallbacks = [ :en ]`). Don't add `config.i18n.fallbacks = true` to `config/environments/production.rb` (upstream's default): it overrides that and makes `ka` fall back to itself, so every missing key renders "Translation missing".

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
  javascript.{en,ka}.yml     datetime.{en,ka}.yml   # date/time formats, ka month & day names
  rails.{en,ka}.yml          # ka for Rails' own strings: list connectors, validation errors,
                             # attribute names, file-size units (en ships with Rails)
  en.yml ka.yml              # original Rails-generated; layouts + my/menu only
```

Some trees don't live where the name suggests: `my/access_tokens`, `my/passkeys`, `my/pins` keys sit under a `my:` tree in `users.{en,ka}.yml`; the Playground onboarding cards (`Account::Seeder`) are `account.seeder.cards` in `account.{en,ka}.yml`.

**When adding new strings:** put them in the namespaced file that matches the area, not `en.yml`/`ka.yml`. Mirror the key tree across both `en` and `ka` files, then run `bin/i18n-check` (no Rails boot needed). It checks en→ka key parity, that every lazy `t(".key")` and literal full-path key resolves in both locales, and that no YAML file has duplicate keys (a later duplicate silently replaces the earlier block).

### How strings are looked up

| Where | API | Example |
|---|---|---|
| ERB views | Lazy lookup `t(".key")` | In `app/views/boards/show.html.erb` → resolves `boards.show.key` |
| Helpers | Full path `I18n.t("...")` | `I18n.t("helpers.cards.added_by", name: ...)` |
| Controllers (flash messages) | Full path | `notice: I18n.t("flashes.saved")` |
| Mailers | Lazy in views, full path in subjects | `mail(subject: I18n.t("magic_link_mailer.sign_in_instructions.subject"))` — no `mailers.` prefix: `ApplicationMailer` appends `app/views/mailers` to the view paths, so `app/views/mailers/foo_mailer/bar.html.erb` looks up `foo_mailer.bar.key` |
| Models (user-visible text) | Full path `I18n.t("...")` | `Event::Description` → `events.description.*`, `Card::Eventable::SystemCommenter` → `events.system_comments.*_html`, `Filter::Summarized` → `filters.summary.*` |
| Dates and times | `l(time, format: :name)` / `I18n.l` — never `strftime` for anything user-visible | formats in `time.formats` (`card_stamp`, `month_day`, `notification_bundle`); the `en` format must reproduce the old `strftime` output |
| JS (Stimulus) | `import { t } from "lib/i18n"` | `t("local_time.x_days_ago.other", { count })` |

When upstream builds a sentence in Ruby (`"#{creator} moved #{card} to …"`), move the whole sentence into YAML with `%{placeholders}` — don't translate fragments. Keep existing `h(...)` escaping on the interpolated values exactly where it was; upstream tests check that names are escaped exactly once.

**Fragment caches:** the activity feed caches each event's HTML (`app/views/events/_event.html.erb`). Changing text that comes from a model or helper doesn't change the template digest, so bump the `<%# … Dependency Updated: … %>` comment in the cached template or users keep seeing old strings.

### JS i18n plumbing

JavaScript can't reach Rails `I18n` directly, so:

- `app/helpers/javascript_translations_helper.rb` emits a `<script id="js-i18n" type="application/json">…</script>` tag containing the entire `javascript:` subtree of the active locale.
- `app/views/layouts/shared/_head.html.erb` calls `<%= javascript_translations_tag %>`.
- `app/javascript/lib/i18n.js` reads that JSON and exposes `t(key, vars)` with `%{var}` interpolation.
- New JS-side strings → add under `javascript:` namespace in `javascript.en.yml` + `javascript.ka.yml` and `import { t } from "lib/i18n"` in the controller.
- Pluralization uses `.one`/`.other` keys; pass `{ count: n }` and pick the form in the controller (`count === 1 ? "one" : "other"`). Georgian doesn't really inflect plurals on time-units, so both forms are usually identical text.

### Tests

The test environment defaults to `:en` (`config/environments/test.rb`) so upstream's English assertions keep passing. Keep `test/` identical to upstream — don't localize assertions.

### Georgian terminology (user-approved)

- Actions by a person: passive + `%{creator}-ის მიერ` (`გადატანილია „დასრულებული“-ში %{creator}-ის მიერ`), not active + ergative `-მა`. In the activity feed the creator is rendered twice (a "You" span and a name span, one hidden by CSS), so the `-ის მიერ` lives inside `events.description.you` / `.creator` (`თქვენ მიერ` / `%{name}-ის მიერ`).
- One Georgian label per UI concept, everywhere: Not now = **„ახლა არა“**, Done column = **„დასრულებული“** (`„დასრულდა“` only as a verb, "the import finished"; dialog "Done" buttons are `მზადაა`), Maybe? = `„იქნებ?“`.
- `ყველას` (dative) for "Everyone"; `მოგნიშნათ` for @mentions.
- When text refers to a UI element ("select X in the sidebar"), quote the exact `ka` label that element renders.

### What NOT to translate

- Brand names: **Fizzy, Basecamp, 37signals, HEY, Playground**.
- CSS classes, ids, `data-*` programmatic values, hrefs, icon names, Stimulus controller/action strings, HTTP headers, JS event codes (`"Digit5"`, `"Escape"` etc.).
- OS/browser UI labels referenced inside install/permission instructions (e.g. "System Settings…") — those refer to actual system UI users must locate visually.
- Deliberately left English (user decision, don't re-propose): static error pages `public/*.html`, PWA manifest description/shortcuts, JSON API error messages, and content already stored in the DB (existing Playground cards, past system comments).

### Soft spots — known translation issues to flag

Georgian uses agglutinative case suffixes that vary by the ending vowel of the noun. Interpolated names (e.g. `%{creator}-მა`) won't always read perfectly. Specific spots flagged for native review:

- `helpers.ka.yml`, `events.ka.yml` — templates with `%{creator}-ის მიერ` / `%{names}-ზე`; the suffix is grammatically off for some name endings (accepted trade-off).
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

CI on push: only the **OSS** test jobs mean anything. The SaaS jobs always fail on the fork (they need Basecamp's private gems). The local Ruby doesn't match `.ruby-version` (3.4.8), so Rails can't boot locally — rely on CI for tests and `bin/i18n-check` for locale files.

The final `deploy` job POSTs to `https://coolify.ordunet.ge/api/v1/deploy?uuid=…&force=false` (Coolify rejects GET with 405) with a bearer token from the `COOLIFY_DEPLOY_TOKEN` GH Actions secret (rotate via `gh secret set COOLIFY_DEPLOY_TOKEN --repo devius/fizzy`). It only runs on the `i18n-georgian` branch.

Coolify service: `fizzy-kanban-netwizard` (uuid `azerkg84md07vqn5b4jzx7aj`, app `fizzy` `hmct7zdwlkvctx0p7yem4ea9`), served at `https://support.netwizard.ge`. With an API token you can read logs (`GET /api/v1/services/<svc>/applications/<app>/logs?lines=N`), read/patch env vars (`/services/<svc>/envs`), and restart (`POST /services/<svc>/restart`) — env changes need a restart. After an API restart Coolify's status may say `exited` while the app is fine; check `/up`. Migrations run on boot (`bin/docker-entrypoint` → `db:prepare`).

Mail: `SMTP_ADDRESS` must be `mail.ordunet.ge` — the mail server's certificate doesn't cover `mail.karchava.ge`, and Rails rejects the hostname mismatch.

The Coolify compose for this fork only differs from upstream in the `image:` line:

```yaml
image: 'ghcr.io/devius/fizzy:i18n-georgian'   # was ghcr.io/basecamp/fizzy:main
```

## Working with upstream

- `origin` → `devius/fizzy`
- `upstream` → `basecamp/fizzy`

Pull upstream changes with `git fetch upstream && git rebase upstream/main` on the `i18n-georgian` branch. New views from upstream will arrive untranslated; English fallback keeps them working until they get `t()` calls.

Checklist (first done 2026-09-28, 244 upstream commits; backup tag `pre-rebase-2026-09-28`):

1. Tag the current branch as a backup and push the tag.
2. Rebase. Resolve view conflicts by taking upstream's markup and re-applying our `t()` calls; accept upstream deletions and drop their now-orphaned keys.
3. Run `bin/i18n-check`, then grep upstream's new/changed views, helpers, models, controllers and JS for hardcoded English and translate it.
4. `git push --force-with-lease`, then watch the OSS CI job and the deploy.

When upstream renames a key/file we use, the lazy lookup path changes — search for the old path in `config/locales/*.yml` and rename to match.

## When to use AGENTS.md vs this file

- **`AGENTS.md`** — Upstream Fizzy domain (multi-tenancy URL slugs, entropy auto-postpone, Solid Queue, sharded search, deploy via Kamal, etc.). Read first.
- **This file** — Anything specific to the i18n layer or this fork's deploy.

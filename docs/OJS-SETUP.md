# OJS Integration & Setup — AJAM

How the **Open Journal Systems** (OJS) submission platform is wired into the AJAM
website and how to install, configure, and operate it.

```
                       ┌──────────── Nginx (web) :8080 ────────────┐
   browser  ──────────▶│  /        →  static Astro site  (./dist)  │
                       │  /ojs/    →  reverse proxy ───────────────┼──▶ ojs (Apache/PHP) :80
                       └───────────────────────────────────────────┘            │
                                                                                 ▼
                                                                          db (MariaDB)
```

Everything lives in one domain: the marketing/info site at `/`, the journal
management + peer-review + full-text system at `/ojs`. The site's "Submit",
"Login", "Register", and "Archive" links (defined in `src/data/site.ts` → `ojs`)
already point at this subpath.

---

## 1. Prerequisites

- Docker Engine + Docker Compose v2 (`docker compose version`)
- Node.js 18+ (to build the static site into `./dist`)

## 2. First-time bring-up

```bash
cp .env.example .env          # then EDIT — set DB_PASSWORD and DB_ROOT_PASSWORD
npm install
npm run build                 # generates ./dist (served by Nginx)
docker compose up -d          # pulls MariaDB, OJS, Nginx and starts them
```

Check status: `docker compose ps` — wait until `db` is healthy and `ojs` is up.

## 3. Install OJS

> **Default access port is `http://localhost:8088`** in this repo (port 8080 was
> already in use on the build machine; change `WEB_HTTP_PORT` in `.env` if you like).

### Option A — headless (recommended, one command)

```bash
bash deploy/install-ojs.sh
```

This runs the OJS installer with the correct database credentials and OJS-3.4
values, then applies the reverse-proxy config. On success it prints the admin
login. **Do not** rely on the image's `PKP_CLI_INSTALL=1` auto-installer — it
runs from the pre-start hook *before* Apache is listening and posts OJS-3.3 form
values (`locale=en_US`, no `timeZone`) that OJS 3.4 rejects. `install-ojs.sh`
fixes both.

Default admin credentials (override via env before running):
`admin` / `adminpass1` — **change the password immediately after first login.**

### Option B — web wizard

Open **http://localhost:8088/ojs** on the host machine. Fill in:

| Field | Value |
|-------|-------|
| Administrator username / password | your own (password ≥ 8 chars) |
| Primary locale | **English** (value `en` — OJS 3.4 uses short codes, not `en_US`) |
| Time zone | pick one (e.g. `UTC`) — **required** |
| **Database driver** | `mysqli` |
| Database host | `db` |
| Database name | `ojs` (matches `DB_NAME`) |
| Database username | `ojs` (matches `DB_USER`) |
| Database password | value of `DB_PASSWORD` from `.env` |
| Files directory | `/var/www/files` (pre-filled) |
| "Create database" | **leave unchecked** — the DB already exists |

After the wizard finishes, run `bash deploy/configure-ojs.sh` (see step 4).

## 4. Reverse-proxy config (applied automatically by Option A)

`deploy/configure-ojs.sh` sets, in `config.inc.php`:
- `base_url[index] = "<OJS_BASE_URL>"` (so OJS emits `/ojs/...` links) — reads
  `OJS_BASE_URL` from `.env`
- `trust_x_forwarded_for = On` (real client IP / HTTPS scheme behind the proxy)
- restarts the `ojs` container.

```bash
bash deploy/configure-ojs.sh
```

> Manual edit instead: `docker compose exec ojs vi /var/www/html/config.inc.php`

> **Host check / "400 Bad Request":** OJS validates the request `Host` against
> `base_url`. Always reach it via the host in `OJS_BASE_URL` (e.g. `localhost`,
> or your production domain) — not via a raw LAN IP. Add extra hostnames to
> `allowed_hosts` in `config.inc.php` if needed.

> **`OJS_DB_*` not `DB_*`:** the pkpofficial image reads `OJS_DB_HOST` /
> `OJS_DB_USER` / `OJS_DB_PASSWORD` / `OJS_DB_NAME`. The compose file maps your
> `.env` `DB_*` values onto those names. The image does **not** inject DB settings
> into `config.inc.php` on its own — they are written by the installer.

## 5. Create the journal

Log in as admin → **Hosted Journals** → *Create Journal*:
- Title: **Algerian Journal of Applied Mathematics**
- **Path: `ajam`** — this MUST match `journalPath` in `src/data/site.ts`, because
  the static site's *Submit* / *Issues* links point at `/ojs/ajam/...`. (Change
  one or the other if you prefer a different path, then rebuild the site.)
- Initial language: English

> Until this journal exists, the site-level links (login, register) work but the
> journal-scoped links (submit, current issue, archive) return 404 — that is
> expected; they light up the moment the `ajam` journal is created.

**Headless alternative:** instead of the UI, run

```bash
bash deploy/create-journal.sh
```

which logs in as admin and creates the `ajam` journal through the OJS REST API
(`POST /_/api/v1/contexts`) — this seeds default sections/genres/user groups, so
submissions work immediately. Override defaults with `OJS_JOURNAL_PATH`,
`OJS_ADMIN_PASS`, etc.

### Subpath serving (how `/ojs` actually works here)

OJS is served *under* `/ojs` without breaking its static assets. Two pieces:
- **Nginx** passes the full `/ojs/...` path through (no prefix stripping):
  `location /ojs { proxy_pass http://ojs_backend; }` with `Host $http_host` (keeps
  the port).
- **Apache in the OJS container** (`deploy/ojs/ojs.conf`, mounted over the image
  default) has `Alias /ojs -> /var/www/html` and `RewriteBase /ojs`. This keeps
  `SCRIPT_NAME = /ojs/index.php`, so OJS computes its base path as `/ojs` and emits
  correct `…:PORT/ojs/lib/…` asset URLs.

If you ever see OJS render with **broken CSS** (asset URLs pointing at
`http://host/lib/...` with no port or no `/ojs`), the cause is almost always the
prefix being stripped or `Host` losing its port — check those two settings, and
that `base_url`/`base_url[index]` in `config.inc.php` both equal your public
`…/ojs` URL (the install template ships a stray `base_url = "https://pkp.sfu.ca/ojs"`
that must be overwritten).

Then in *Journal Settings* fill Masthead, Contact, Sections (Articles, Reviews,
Short Communications), Submission checklist, Author guidelines, Review form, and
the Privacy Statement — mirror the content already written on the static site
(`/for-authors/`, `/for-reviewers/`, `/policies/`).

> Tip: a single-journal install can hide the journal-path segment via
> *Site Settings → redirect to a single journal*, so submission URLs read cleanly.

---

## Gating OJS to a login/submission portal

The public reading interface (current issue, archive, about) lives on the static
Astro site, so OJS is used only as the login / registration / submission system.
Two settings enforce that:

1. **Redirect visitors to login** — the journal's `restrictSiteAccess` flag is on
   ("users must register and log in to view the journal"). Any unauthenticated hit
   on `/ojs/ajam…` 302-redirects to the login page. Set via API:
   `PUT /ojs/ajam/api/v1/contexts/1  {"restrictSiteAccess":true}` (or in the UI:
   Settings → Website → Setup → Site Access Options). Reverse by setting it `false`.
2. **Hide the Current / Archive / About tabs** — Nginx injects a small CSS rule
   (`#navigationPrimary{display:none}`) into OJS HTML via `sub_filter` (see the
   `/ojs` block in `deploy/nginx/ajam.conf`). Register/Login (a separate user-nav
   list) stay visible. Remove the `sub_filter` line to restore the tabs.

> Trade-off: `restrictSiteAccess` also blocks anonymous access to article landing
> pages and may reduce what Google Scholar / OAI harvesters can read directly from
> OJS. Fine while OJS is submission-only; revisit if you later want OJS to serve
> public full text for indexing.

## Production deployment

1. **Domain & HTTPS** — put this stack behind your real hostname
   (`ajam.univ-ouargla.dz`) and terminate TLS. Either:
   - add a TLS server block + certs (Let's Encrypt / certbot) to
     `deploy/nginx/ajam.conf`, **or**
   - run the stack behind the university's existing HTTPS load balancer.
2. **Update URLs** for the real domain:
   - `.env` → `WEB_HTTP_PORT`, `SERVERNAME=ajam.univ-ouargla.dz`,
     `OJS_BASE_URL=https://ajam.univ-ouargla.dz/ojs`
   - `astro.config.mjs` → `SITE`
   - re-run `npm run build` and `bash deploy/configure-ojs.sh`
3. **Secrets** — strong unique `DB_PASSWORD` / `DB_ROOT_PASSWORD`; never commit `.env`.
4. **Pin images** — replace floating tags with digests (`pkpofficial/ojs@sha256:…`).
5. **Email** — configure SMTP in `config.inc.php` `[email]` so OJS can send
   submission / review / decision notifications.
6. **DOIs** — enable the Crossref plugin once a DOI prefix is registered.
7. **Indexing** — the OAI endpoint is `/ojs/index.php/<journal>/oai`; register it
   with DOAJ, BASE, Google Scholar, etc. (see `/indexing/`).

## Backups

Two things to back up regularly:
- **Database** — `docker compose exec db mariadb-dump -u root -p"$DB_ROOT_PASSWORD" ojs > backup.sql`
- **Uploaded files** — the `./volumes/private` directory (submissions) and
  `./volumes/public` (published galleys, journal logos).

## Common operations

```bash
docker compose logs -f ojs        # tail OJS / Apache logs
docker compose restart ojs        # apply config changes
docker compose down               # stop (keeps ./volumes data)
docker compose down -v            # stop AND wipe named volumes (data in ./volumes stays)
docker compose exec ojs bash      # shell into the OJS container
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `/ojs` shows broken CSS / wrong links | `base_url[index]` not set to `.../ojs` → run `deploy/configure-ojs.sh` |
| Login loops / "page expired" | proxy headers missing → confirm `trust_x_forwarded_for = On` |
| "Allowed hosts" / host check error | add your domain to `allowed_hosts` in `config.inc.php` |
| Upload fails on large files | raise `client_max_body_size` (Nginx) and PHP `upload_max_filesize` |
| `db` unhealthy | check `DB_PASSWORD` matches between `.env` and what OJS installer used |
| After restart OJS shows the **installer again** (DB still has data) | `config.inc.php` wasn't persisted — the image regenerates a default (`installed = Off`) on a fresh container. Ensure the config bind mount is enabled in `docker-compose.yml` (`./volumes/config/ojs.config.inc.php:/var/www/html/config.inc.php`) and the host file holds the installed config. |

> **Config persistence:** OJS stores install state in `config.inc.php`, which lives
> inside the container by default and is lost on recreate. This stack bind-mounts it
> from `./volumes/config/ojs.config.inc.php` so it survives restarts. That file must
> exist before the `ojs` container starts (a Docker single-file bind mount of a
> missing path creates an empty directory and breaks OJS). For a clean first install,
> bring the stack up once with that mount line commented out, run
> `deploy/install-ojs.sh`, copy the config to the host
> (`docker compose cp ojs:/var/www/html/config.inc.php ./volumes/config/ojs.config.inc.php`),
> then uncomment the mount and `docker compose up -d --force-recreate ojs`.

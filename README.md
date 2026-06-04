# Algerian Journal of Applied Mathematics (AJAM) — Website

Official website for the **Algerian Journal of Applied Mathematics**, published by the
**Laboratory of Applied Mathematics**, Kasdi Merbah University, Ouargla, Algeria.

Built with **[Astro](https://astro.build)** — a static site generator that ships zero
JavaScript by default, giving a fast, SEO-friendly, low-maintenance journal site. The
manuscript submission/peer-review workflow runs on a **self-hosted Open Journal Systems
(OJS)** instance, linked from the site under the `/ojs` path.

---

## Quick start

```bash
npm install        # install dependencies
npm run dev        # local dev server at http://localhost:4321
npm run build      # production build → ./dist
npm run preview    # preview the production build
```

Requires Node.js 18+ (developed on Node 24).

### Full integrated stack (site + OJS + database)

The submission system is real: a Docker Compose stack runs Nginx (front door),
Open Journal Systems, and MariaDB together. Nginx serves the static site at `/`
and reverse-proxies OJS at `/ojs`.

```bash
cp .env.example .env          # edit DB passwords
npm install && npm run build  # build the static site into ./dist
docker compose up -d          # start db + ojs + nginx
bash deploy/install-ojs.sh    # one-time OJS install (prints admin login)
```

Then open **http://localhost:8088/** (site) and **http://localhost:8088/ojs**
(journal system). Full details, production HTTPS, backups, and troubleshooting:
[`docs/OJS-SETUP.md`](docs/OJS-SETUP.md).

---

## Project structure

```
ajam/
├── astro.config.mjs        # site URL, sitemap, host config
├── src/
│   ├── data/site.ts        # ★ SINGLE SOURCE OF TRUTH — all journal content/data
│   ├── layouts/Base.astro  # HTML shell, <head>, SEO + scholarly meta
│   ├── components/
│   │   ├── Header.astro     # sticky nav + "Submit" button
│   │   ├── Footer.astro     # footer with links + contact
│   │   └── PageHeader.astro # reusable inner-page banner
│   ├── styles/global.css    # design tokens (green/sand palette) + utility classes
│   └── pages/               # one file = one route
│       ├── index.astro          /
│       ├── aims-and-scope.astro  /aims-and-scope/
│       ├── editorial-board.astro /editorial-board/
│       ├── for-authors.astro     /for-authors/
│       ├── for-reviewers.astro   /for-reviewers/
│       ├── policies.astro        /policies/      (ethics & editorial policies)
│       ├── issues.astro          /issues/
│       ├── indexing.astro        /indexing/
│       ├── contact.astro         /contact/
│       └── 404.astro             not-found page
└── public/                  # favicon, robots.txt (served as-is)
```

---

## Editing content

**Most edits happen in one file: `src/data/site.ts`.** It holds the journal title,
ISSN, contact details, navigation, subject areas, editorial board, and indexing lists.
Pages read from it, so changing a value there updates every page that uses it.

### Things you MUST replace before going live
Values marked `PLACEHOLDER` in `src/data/site.ts`:
- `journal.issnOnline` — request the ISSN from the national centre (CERIST).
- `contact.*` — real email addresses, phone, postal address.
- `editorialBoard.*` — real names and affiliations (currently bracketed placeholders).
- `astro.config.mjs` → `SITE` — the real public domain.
- Author templates: drop `ajam-template.zip` into `public/templates/` (linked from
  `/for-authors/`).

---

## OJS (Open Journal Systems) integration

The site is a **static front door**; OJS handles accounts, submissions, peer review,
and full-text hosting. All OJS links live in `src/data/site.ts` under the `ojs` object
and currently point to the **`/ojs` subpath** of the same domain:

```
/ojs                       OJS home
/ojs/about/submissions     submission info
/ojs/login                 author/reviewer login
/ojs/user/register         registration
/ojs/issue/current         current issue
/ojs/issue/archive         archive
```

### Recommended deployment topology
Serve the static site at `/` and reverse-proxy OJS at `/ojs` so everything sits on one
domain (`ajam.univ-ouargla.dz`). Example **Nginx**:

```nginx
server {
    server_name ajam.univ-ouargla.dz;

    # Static Astro site
    root /var/www/ajam/dist;
    location / {
        try_files $uri $uri/ /404.html;
    }

    # Self-hosted OJS (PHP) under /ojs
    location /ojs/ {
        proxy_pass http://127.0.0.1:8080/;   # OJS app (e.g. PHP-FPM container)
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
```

In OJS `config.inc.php`, set `base_url[index] = "https://ajam.univ-ouargla.dz/ojs"` and
enable `restful_urls`/`disable_path_info` as appropriate so OJS generates correct links
behind the `/ojs` prefix.

> If you instead host OJS on a separate subdomain (e.g. `https://ojs.univ-ouargla.dz`),
> just change the `ojs` URLs in `src/data/site.ts` to absolute URLs — nothing else needs
> to change.

---

## Deployment

`npm run build` outputs a fully static `./dist` folder. Host it on any static server
(Nginx, Apache, GitHub Pages, Netlify, university web server). Update `SITE` in
`astro.config.mjs` to the production domain first so the sitemap and canonical URLs are
correct.

A `sitemap-index.xml` and `robots.txt` are generated/served automatically for SEO.

---

## Design notes

University-branded palette (deep green + desert sand + gold), serif headings, accessible
focus styles, skip link, and responsive mobile nav. Tokens are defined as CSS custom
properties at the top of `src/styles/global.css` — change them there to re-theme the
whole site.
```
--green-900 #0f3d2e   --sand-500 #c8a96a   --gold #b9892f
```

---

*Powered by Open Journal Systems · Built with Astro.*

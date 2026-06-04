import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Public site URL and base path.
// Defaults target GitHub Pages project site: https://sawat80.github.io/ajam/
// Override via env when deploying elsewhere, e.g.:
//   SITE_URL=https://ajam.univ-ouargla.dz BASE_PATH=/ npm run build
const SITE = process.env.SITE_URL || 'https://sawat80.github.io';
const BASE = process.env.BASE_PATH || '/ajam';

export default defineConfig({
  site: SITE,
  base: BASE,
  integrations: [sitemap()],
  build: {
    inlineStylesheets: 'auto',
  },
  vite: {
    // allow the dockerized preview browser to reach the dev/preview server
    preview: { allowedHosts: true },
    server: { allowedHosts: true },
  },
});

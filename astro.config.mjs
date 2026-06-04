import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Public site URL — change to the real domain when deploying.
const SITE = 'https://ajam.univ-ouargla.dz';

export default defineConfig({
  site: SITE,
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

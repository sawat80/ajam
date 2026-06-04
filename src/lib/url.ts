/**
 * Base-path-aware URL helper.
 *
 * GitHub Pages serves this project under a subpath (e.g. /ajam/), set via the
 * `base` option in astro.config.mjs and exposed as import.meta.env.BASE_URL.
 * Internal links written as "/foo/" must be prefixed with that base, otherwise
 * they 404 on Pages. External/absolute links and mailto: pass through unchanged.
 *
 * Usage:  import { u } from '../lib/url';  <a href={u('/aims-and-scope/')}>
 */
const BASE = import.meta.env.BASE_URL; // always ends with '/', e.g. '/ajam/' or '/'

export function u(path: string): string {
  if (!path) return BASE;
  if (/^(https?:)?\/\//.test(path) || path.startsWith('mailto:') || path.startsWith('#')) {
    return path; // external, protocol-relative, mailto, or in-page anchor
  }
  const clean = path.startsWith('/') ? path : `/${path}`;
  return `${BASE.replace(/\/$/, '')}${clean}`;
}

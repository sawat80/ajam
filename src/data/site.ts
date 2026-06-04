/**
 * Central journal data — single source of truth for the whole site.
 * Edit values here; every page reads from this file.
 * Values marked "PLACEHOLDER" must be confirmed by the editorial office.
 */

export const journal = {
  title: 'Algerian Journal of Applied Mathematics',
  shortTitle: 'AJAM',
  tagline: 'Open-access research in applied and computational mathematics',
  issnOnline: 'XXXX-XXXX', // PLACEHOLDER — request from CERIST/ISSN national centre
  issnPrint: '', // leave empty if online-only
  publisher: 'Laboratory of Applied Mathematics',
  institution: 'Kasdi Merbah University, Ouargla',
  institutionShort: 'University of Ouargla',
  country: 'Algeria',
  foundedYear: 2025,
  frequency: 'Biannual (2 issues per year: June & December)',
  language: 'English',
  reviewModel: 'Double-blind peer review',
  accessModel: 'Diamond Open Access — free to read and free to publish (no APC)',
  license: 'CC BY 4.0',
  domain: 'ajam.univ-ouargla.dz',
};

/**
 * OJS (Open Journal Systems) — self-hosted, reverse-proxied under /ojs.
 * URL scheme matches OJS 3.4 (restful_urls On):
 *   - site-level pages live under  /ojs/index/...
 *   - journal-level pages live under  /ojs/<journalPath>/...
 * `journalPath` MUST equal the Path you give the journal when you create it
 * in the OJS admin (see docs/OJS-SETUP.md, step 5). Until that journal exists,
 * the journal-scoped links (submit / issues) will 404 — login/register work
 * immediately.
 */
const OJS_BASE = '/ojs';
const OJS_JOURNAL = 'ajam';
export const ojs = {
  base: OJS_BASE,
  journalPath: OJS_JOURNAL,
  // site-level (work as soon as OJS is installed)
  login: `${OJS_BASE}/index/login`,
  register: `${OJS_BASE}/index/user/register`,
  // journal-level (work once the "${OJS_JOURNAL}" journal is created)
  submit: `${OJS_BASE}/${OJS_JOURNAL}/about/submissions`,
  currentIssue: `${OJS_BASE}/${OJS_JOURNAL}/issue/current`,
  archive: `${OJS_BASE}/${OJS_JOURNAL}/issue/archive`,
};

export const contact = {
  email: 'ajam@univ-ouargla.dz', // PLACEHOLDER
  editorialEmail: 'editor.ajam@univ-ouargla.dz', // PLACEHOLDER
  phone: '+213 (0) 29 XX XX XX', // PLACEHOLDER
  addressLines: [
    'Laboratory of Applied Mathematics',
    'Faculty of Mathematics and Material Sciences',
    'Kasdi Merbah University',
    'BP 511, Route de Ghardaïa, 30000 Ouargla',
    'Algeria',
  ],
};

/** Primary navigation — used by Header on every page */
export const nav = [
  { label: 'Home', href: '/' },
  { label: 'Aims & Scope', href: '/aims-and-scope/' },
  { label: 'Editorial Board', href: '/editorial-board/' },
  { label: 'For Authors', href: '/for-authors/' },
  { label: 'For Reviewers', href: '/for-reviewers/' },
  { label: 'Ethics & Policies', href: '/policies/' },
  { label: 'Issues', href: '/issues/' },
  { label: 'Indexing', href: '/indexing/' },
  { label: 'Contact', href: '/contact/' },
];

/** Subject areas — drives Aims & Scope and the home grid */
export const subjects = [
  { name: 'Numerical Analysis & Scientific Computing', icon: '∑' },
  { name: 'Ordinary & Partial Differential Equations', icon: '∂' },
  { name: 'Optimization & Operations Research', icon: '↘' },
  { name: 'Probability, Statistics & Data Science', icon: 'σ' },
  { name: 'Dynamical Systems & Control Theory', icon: '∮' },
  { name: 'Mathematical Modelling in Engineering & Biology', icon: '∞' },
  { name: 'Functional Analysis & Operator Theory', icon: '⊗' },
  { name: 'Fractional Calculus & Integral Equations', icon: '∫' },
];

/** Editorial board — PLACEHOLDER names; replace with real members. */
export const editorialBoard = {
  editorInChief: {
    name: 'Prof. [Editor-in-Chief Name]',
    affiliation: 'Laboratory of Applied Mathematics, University of Ouargla, Algeria',
    email: 'editor.ajam@univ-ouargla.dz',
  },
  managingEditors: [
    { name: 'Dr. [Managing Editor 1]', affiliation: 'University of Ouargla, Algeria' },
    { name: 'Dr. [Managing Editor 2]', affiliation: 'University of Ouargla, Algeria' },
  ],
  associateEditors: [
    { name: 'Prof. [Associate Editor 1]', field: 'Numerical Analysis', affiliation: 'University of Algiers, Algeria' },
    { name: 'Prof. [Associate Editor 2]', field: 'PDEs', affiliation: 'University of Constantine, Algeria' },
    { name: 'Prof. [Associate Editor 3]', field: 'Optimization', affiliation: 'University of Oran, Algeria' },
    { name: 'Dr. [Associate Editor 4]', field: 'Probability & Statistics', affiliation: 'University of Setif, Algeria' },
  ],
  advisoryBoard: [
    { name: 'Prof. [International Member 1]', affiliation: 'Sorbonne Université, France' },
    { name: 'Prof. [International Member 2]', affiliation: 'King Abdullah University (KAUST), Saudi Arabia' },
    { name: 'Prof. [International Member 3]', affiliation: 'Politecnico di Milano, Italy' },
  ],
};

/** Indexing targets — distinguishes current vs. applied-for. */
export const indexing = {
  current: [
    { name: 'Google Scholar', note: 'Auto-harvested via OJS metadata' },
    { name: 'Algerian Scientific Journals Platform (ASJP)', note: 'National platform — DGRSDT' },
  ],
  appliedFor: [
    { name: 'DOAJ — Directory of Open Access Journals' },
    { name: 'zbMATH Open' },
    { name: 'Mathematical Reviews (MathSciNet)' },
    { name: 'Scopus' },
    { name: 'Crossref (DOI registration)' },
  ],
};

export const social = {
  // PLACEHOLDER — add when accounts exist
  researchgate: '',
  linkedin: '',
};

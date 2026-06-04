# AJAM LaTeX Template

Official manuscript template for the **Algerian Journal of Applied Mathematics
(AJAM)**, Laboratory of Applied Mathematics, Kasdi Merbah University, Ouargla,
Algeria.

## Files
| File | Purpose |
|------|---------|
| `ajam.cls` | Journal document class — **do not edit** |
| `ajam-template.tex` | Your manuscript — edit this |
| `references.bib` | Your bibliography (BibTeX) |
| `logos/univ-ouargla.pdf` | University of Ouargla emblem (first page) |
| `logos/univ-ouargla.tex` | Source of the placeholder emblem |
| `README.md` | This file |

## Logos
- The **AJAM ∑ mark** beside the journal name (in the banner and the running
  head) is drawn in vector form by the class — no image file, nothing to do.
- The **University of Ouargla logo** on the first page is loaded from
  `logos/univ-ouargla.pdf`. A placeholder is shipped; **replace it with the
  official logo** (keep the name `univ-ouargla.pdf`, or use `univ-ouargla.png`).
  If the file is missing, the banner simply omits the logo.

## How to compile

**Overleaf (easiest):** upload the whole folder, open `ajam-template.tex`, and set
the compiler to **pdfLaTeX** (Menu → Compiler). Click Recompile.

**Local (TeX Live / MiKTeX):**
```
pdflatex ajam-template
bibtex   ajam-template
pdflatex ajam-template
pdflatex ajam-template
```

## What the class gives you
- AJAM title banner (volume/issue/year/pages/DOI), running heads, open-access footer.
- `authblk` author/affiliation handling; `\corresponding{email}` note.
- Abstract block with **Keywords** and **2020 MSC** classification.
- Theorem environments: `theorem, lemma, proposition, corollary, conjecture,
  definition, assumption, example, problem, remark, notation` (shared counter,
  numbered by section), plus a `proof` environment.
- `amsmath`, `amssymb`, `mathtools`, `cleveref` (`\Cref{...}`), `natbib`
  (numeric `[1]` citations), `booktabs` tables, `graphicx` figures.
- Shortcuts: `\R \N \Z \C`, `\argmin \argmax \diver`.

## Setting metadata
Edit the preamble of `ajam-template.tex`:
```latex
\journalvolume{1} \journalissue{1} \journalyear{2026} \journalpages{1--15}
\title{...} \shorttitle{...} \shortauthors{...}
\keywords{...} \subjclass{Primary 65N30; Secondary 35J20}
\corresponding{email@univ-ouargla.dz}
```
The editorial office sets volume/issue/pages/DOI on acceptance; leave the
defaults if unsure.

## Double-blind review
AJAM uses double-blind peer review. For the **initial submission**:
1. Remove author names, affiliations, and the `\corresponding` line.
2. Remove the **Acknowledgements** section and any funding/identifying notes.
3. Refer to your own prior work in the third person.
4. Upload the anonymised PDF, plus a **separate title page** (with full author
   details) as instructed in the Author Guidelines.

## Submission
Submit via the AJAM Open Journal Systems platform (see the journal website,
**For Authors**). Upload the source files (`.tex`, `.bib`, figures) and the
compiled PDF.

---
*Distributed for use by AJAM authors. The journal publishes under CC BY 4.0.*

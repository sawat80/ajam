%% ajam.cls — Document class for the
%% Algerian Journal of Applied Mathematics (AJAM)
%% Published by the Laboratory of Applied Mathematics,
%% Kasdi Merbah University, Ouargla, Algeria.
%%
%% Compile with pdflatex (run: pdflatex -> bibtex -> pdflatex x2).
%% Requires a standard TeX Live / MiKTeX installation.
%% ---------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ajam}[2026/06/04 v1.0 Algerian Journal of Applied Mathematics]

% Pass any unknown options to the base article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[11pt,a4paper,twoside]{article}

% ---- Fonts & encoding (pdflatex) ----
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{lmodern}
\RequirePackage{microtype}

% ---- Page geometry ----
\RequirePackage[a4paper,top=2.6cm,bottom=2.6cm,left=2.4cm,right=2.4cm,
                headheight=14pt,footskip=1.1cm]{geometry}
\RequirePackage{setspace}

% ---- Math ----
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{amsthm}
\RequirePackage{mathtools}

% ---- Graphics, tables, misc ----
\RequirePackage{graphicx}
\RequirePackage{booktabs}
\RequirePackage{array}
\RequirePackage{caption}
\RequirePackage{enumitem}
\RequirePackage{authblk}

% ---- Colour (AJAM brand: deep green + gold) ----
\RequirePackage{xcolor}
\definecolor{ajamGreen}{HTML}{14543F}
\definecolor{ajamGold}{HTML}{B9892F}
\definecolor{ajamInk}{HTML}{1C2420}
\definecolor{ajamSand}{HTML}{C8A96A}

% ---- AJAM sigma mark (vector, drawn with TikZ — no image file needed) ----
\RequirePackage{tikz}
% Base design in a 10pt x 10pt box: gold rounded square + green capital sigma.
\newcommand{\ajammarkbase}{%
  \begin{tikzpicture}
    \fill[ajamSand,rounded corners=2pt] (0,0) rectangle (10pt,10pt);
    \node[ajamGreen,inner sep=0pt] at (5pt,4.6pt)
      {\fontsize{8pt}{8pt}\selectfont\bfseries$\Sigma$};
  \end{tikzpicture}%
}
% \ajammark{<height>} — the mark scaled to the requested height, vertically centred.
\newcommand{\ajammark}[1]{\raisebox{-0.18\height}{\resizebox{!}{#1}{\ajammarkbase}}}

% ---- University of Ouargla logo loader ----
% Drop the official logo as logos/univ-ouargla.{pdf,png,jpg}. A vector
% placeholder is shipped; replace it with the real logo. If the file is
% absent, the first-page banner gracefully omits the logo.
\newcommand{\univlogo}{%
  \IfFileExists{logos/univ-ouargla.pdf}%
    {\includegraphics[height=1.45cm]{logos/univ-ouargla}}%
    {\IfFileExists{logos/univ-ouargla.png}%
       {\includegraphics[height=1.45cm]{logos/univ-ouargla.png}}%
       {}}%
}
\newif\if@ajamhaslogo
\IfFileExists{logos/univ-ouargla.pdf}{\@ajamhaslogotrue}{%
  \IfFileExists{logos/univ-ouargla.png}{\@ajamhaslogotrue}{\@ajamhaslogofalse}}

% ---- Bibliography (numeric, square brackets) ----
\RequirePackage[numbers,sort&compress,square,comma]{natbib}
\bibliographystyle{plainnat}
\setlength{\bibsep}{2pt}

% ---- Hyperlinks & cross-references (load late) ----
\RequirePackage[colorlinks=true,allcolors=ajamGreen,breaklinks=true]{hyperref}
\RequirePackage[capitalise,noabbrev]{cleveref}

% ===============================================================
%  Journal metadata — set in the manuscript preamble; have defaults
% ===============================================================
\newcommand{\@journalname}{Algerian Journal of Applied Mathematics}
\newcommand{\@journalshort}{Algerian J. Appl. Math.}
\newcommand{\@journalissn}{XXXX--XXXX}
\newcommand{\@jvol}{1}\newcommand{\journalvolume}[1]{\renewcommand{\@jvol}{#1}}
\newcommand{\@jiss}{1}\newcommand{\journalissue}[1]{\renewcommand{\@jiss}{#1}}
\newcommand{\@jyear}{20XX}\newcommand{\journalyear}[1]{\renewcommand{\@jyear}{#1}}
\newcommand{\@jpages}{1--XX}\newcommand{\journalpages}[1]{\renewcommand{\@jpages}{#1}}
\newcommand{\@jdoi}{}\newcommand{\articledoi}[1]{\renewcommand{\@jdoi}{#1}}
\newcommand{\@received}{}\newcommand{\received}[1]{\renewcommand{\@received}{#1}}
\newcommand{\@revised}{}\newcommand{\revised}[1]{\renewcommand{\@revised}{#1}}
\newcommand{\@accepted}{}\newcommand{\accepted}[1]{\renewcommand{\@accepted}{#1}}
\newcommand{\@published}{}\newcommand{\published}[1]{\renewcommand{\@published}{#1}}

% Keywords, MSC subject classification, corresponding author
\newcommand{\@keywords}{}\newcommand{\keywords}[1]{\renewcommand{\@keywords}{#1}}
\newcommand{\@subjclass}{}\newcommand{\subjclass}[1]{\renewcommand{\@subjclass}{#1}}
\newcommand{\@corraddr}{}\newcommand{\corresponding}[1]{\renewcommand{\@corraddr}{#1}}

% Short running title (defaults to full title if unset)
\newcommand{\@shorttitle}{}\newcommand{\shorttitle}[1]{\renewcommand{\@shorttitle}{#1}}
\newcommand{\@shortauthors}{}\newcommand{\shortauthors}[1]{\renewcommand{\@shortauthors}{#1}}

% ---- Theorem environments (math journal) ----
\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{conjecture}[theorem]{Conjecture}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{assumption}[theorem]{Assumption}
\newtheorem{example}[theorem]{Example}
\newtheorem{problem}[theorem]{Problem}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{notation}[theorem]{Notation}

% Common math operators / shortcuts
\DeclareMathOperator{\diver}{div}
\DeclareMathOperator*{\argmin}{arg\,min}
\DeclareMathOperator*{\argmax}{arg\,max}
\newcommand{\R}{\mathbb{R}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\C}{\mathbb{C}}
\renewcommand{\qedsymbol}{$\blacksquare$}

% ---- Running heads & first-page banner (fancyhdr) ----
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}

\fancypagestyle{ajamfirst}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0pt}%
  \fancyfoot[C]{%
    \footnotesize\color{ajamInk}%
    \rule{\textwidth}{0.4pt}\\[2pt]%
    \textcolor{ajamGreen}{\textbf{\@journalshort}}\space
    \textbf{\@jvol}(\@jiss) (\@jyear) \@jpages.%
    \ifx\@jdoi\@empty\else\space DOI:\,\@jdoi.\fi\\[1pt]%
    \textcolor{ajamGold}{\textbf{Open access}} --- distributed under CC\,BY\,4.0.\space
    \textcopyright\,\@jyear\ the author(s).%
  }%
  \fancyfoot[R]{\footnotesize\thepage}%
}

\fancypagestyle{ajammain}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0.4pt}%
  \fancyhead[LE]{\footnotesize\textcolor{ajamGreen}{\@shortauthors}}%
  \fancyhead[RO]{\footnotesize\textcolor{ajamGreen}{\itshape\@shorttitle}}%
  \fancyhead[LO,RE]{\footnotesize\ajammark{9pt}\,\textcolor{ajamGreen}{\@journalshort}}%
  \fancyfoot[C]{\footnotesize\thepage}%
}
\pagestyle{ajammain}

% ===============================================================
%  Title block
% ===============================================================
\renewcommand\Authfont{\bfseries\normalsize}
\renewcommand\Affilfont{\mdseries\footnotesize\itshape\color{ajamInk}}
\setlength{\affilsep}{0.6em}

\renewcommand{\maketitle}{%
  \thispagestyle{ajamfirst}%
  % top banner
  \def\ajam@bannertext{%
    \footnotesize\color{ajamInk}%
    \ajammark{12pt}\,\textcolor{ajamGreen}{\textbf{\@journalname}}\hfill ISSN \@journalissn\\[2pt]
    \textcolor{ajamGreen}{\rule{\linewidth}{1pt}}\\[1pt]
    Vol.~\textbf{\@jvol}, No.~\@jiss\ (\@jyear), pp.~\@jpages
    \ifx\@published\@empty\else\hfill Published: \@published\fi
  }%
  \noindent
  \if@ajamhaslogo
    \begin{minipage}[c]{0.18\linewidth}\univlogo\end{minipage}\hfill
    \begin{minipage}[c]{0.79\linewidth}\ajam@bannertext\end{minipage}%
  \else
    \begin{minipage}[c]{\linewidth}\ajam@bannertext\end{minipage}%
  \fi
  \\[1.6em]
  % title
  {\raggedright\color{ajamGreen}\bfseries\LARGE\@title\par}%
  \vskip 1.1em%
  % authors / affiliations via authblk
  {\raggedright\@author\par}%
  \vskip 0.4em%
  \begingroup\footnotesize\color{ajamInk}%
    \ifx\@received\@empty\else Received: \@received.\fi
    \ifx\@revised\@empty\else\quad Revised: \@revised.\fi
    \ifx\@accepted\@empty\else\quad Accepted: \@accepted.\fi
    \par
  \endgroup
  \vskip 1.2em%
  \hrule height 0.4pt%
}

% ---- Abstract / keywords / MSC block ----
\renewenvironment{abstract}{%
  \vskip 0.9em%
  \begin{spacing}{1.0}%
  \noindent\textcolor{ajamGreen}{\bfseries Abstract.}\space\small%
}{%
  \par\vskip 0.6em%
  \ifx\@keywords\@empty\else
    \noindent{\small\textcolor{ajamGreen}{\bfseries Keywords.}\space\@keywords\par}%
  \fi
  \ifx\@subjclass\@empty\else
    \noindent{\small\textcolor{ajamGreen}{\bfseries 2020 MSC.}\space\@subjclass\par}%
  \fi
  \ifx\@corraddr\@empty\else
    \vskip 0.3em\noindent{\footnotesize\color{ajamInk}$^{*}$Corresponding author: \@corraddr\par}%
  \fi
  \end{spacing}%
  \vskip 0.4em\hrule height 0.4pt\vskip 1.2em%
}

% Section heading style
\RequirePackage{titlesec}
\titleformat{\section}{\normalfont\large\bfseries\color{ajamGreen}}{\thesection.}{0.5em}{}
\titleformat{\subsection}{\normalfont\normalsize\bfseries\color{ajamGreen}}{\thesubsection.}{0.5em}{}
\titleformat{\subsubsection}{\normalfont\normalsize\itshape\color{ajamInk}}{\thesubsubsection.}{0.5em}{}

\endinput

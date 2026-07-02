# Costlier Candles, Quiet Prophets

**How religion meets inflation in the Croatian digital media space, 2021–2026**

Luka Šikić · Petra Palić, izv. dr. sc. · Catholic University of Croatia (Hrvatsko katoličko sveučilište), Department of Communication Studies · DigiKat project
Working manuscript — first complete version, under revision for *Revija za socijalnu politiku*.

## Read the paper

| Format | Link |
|---|---|
| 📄 PDF | [`paper/paper.pdf`](paper/paper.pdf) |
| 🌐 HTML (rendered) | **[view live](https://raw.githack.com/lusiki/Katoliq_vs_inflation/master/paper/paper.html)** — opens directly in the browser, self-contained |
| 📝 Word | [`paper/paper.docx`](paper/paper.docx) |
| 🔧 Quarto source | [`paper/paper.qmd`](paper/paper.qmd) (renders to all of the above — see [Reproduce](#reproduce-the-paper)) |

## What the paper asks

Catholic Social Teaching gives the Church a distinctive voice in economic hardship — to name inflation as an
injustice that falls hardest on the poor. This paper asks what that voice actually sounds like in a national
digital media space during a real cost-of-living shock, using the DigiKat corpus of **710,307** religion-salient
Croatian/Bosnian media posts (Jan 2021 – Jun 2026).

The central methodological move: **co-occurrence is not engagement**. A news article can mention inflation in
one paragraph and a saint's feast in another with no connection between them. Naively counting posts where
religion and inflation co-occur overstates genuine engagement by roughly an order of magnitude. The paper
instead measures *linkage* — coding a proximity-filtered candidate pool with three independent LLM annotators —
to isolate a **measured domestic core of 520 posts** (0.07% of the corpus) where religion and inflation are
genuinely connected.

## Three findings worth knowing

1. **The funnel is steep.** 710,307 posts → 8,019 mention inflation → 1,450 pass a recall-oriented proximity
   filter → only 652 are confirmed as genuinely religion-linked by human/LLM coding → 520 after excluding
   foreign-country inflation. Even among filter-flagged candidates, well under half survive coding — a caution
   for any "religion and X" corpus study that stops at keyword co-occurrence.

2. **The Church shows up as a price list, not a pulpit.** Within the measured core, ~72% of posts describe
   either the *rising cost of religious life* (masses, weddings, funeral fees — 37%) or the *Church as an
   institution* caught in economic news (34%). The structural, Catholic-Social-Teaching-style justice register —
   "this economy kills," the preferential option for the poor — appears in just **3%** of posts (≤8% under a
   broader latent-language definition). The paper is careful to frame this as a claim about *digital-media
   visibility*, not the Church's actual pastoral conduct — homilies and Caritas fieldwork are structurally
   invisible to a news-monitoring corpus, and a newsroom-gatekeeping rival explanation is discussed explicitly.

3. **Attention tracked prices — partially.** Media attention to inflation correlates strongly with the Croatian
   HICP (Pearson r ≈ 0.73, food r ≈ 0.72) and jumps 2.4× above the literature's ≈4% inflation-attention
   threshold — but the coupling is weaker for energy prices, and the manuscript is explicit that the observational
   design (autocorrelated HICP, an imposed rather than estimated threshold, the January 2023 euro-changeover as
   a confound) licenses "partially supported," not a strong causal claim.

## Repository map

```
Katoliq_vs_inflation/
├── paper/            the manuscript itself — source + every rendered format
│   ├── paper.qmd      Quarto source (single source of truth)
│   ├── paper.md       plain-Markdown version of the same text
│   ├── paper.html     self-contained HTML (all figures embedded, opens standalone)
│   ├── paper.pdf      typeset PDF
│   └── paper.docx     Word, for track-changes review
├── review/            the peer-review round this version responds to
│   ├── REVIEW_REPORT.md     four-reviewer panel report (methods, substance, presentation, ethics)
│   └── REVIEW_RESPONSE.md   point-by-point response from an earlier revision pass
├── scripts/           the numbered analysis pipeline, in run order (see below)
├── R/                 shared R helpers (religious-term lexicon)
└── output/
    ├── figures/        the 6 figures used in the paper, as standalone PNGs
    └── tables/         the 6 published tables (Tables 1–6) as CSV, plus the two
                         aggregate time series (HICP + monthly attention) behind Table 6 / Figure 6
```

## Reproduce the paper

The **document** is fully reproducible from what's in this repo — `paper/paper.qmd` renders to HTML, PDF, and
DOCX with no dependency beyond [Quarto](https://quarto.org) (and a LaTeX distribution such as
[TinyTeX](https://yihui.org/tinytex/) for the PDF target):

```bash
git clone https://github.com/lusiki/Katoliq_vs_inflation.git
cd Katoliq_vs_inflation/paper
quarto render paper.qmd --to html   # or --to pdf / --to docx
```

The figures and tables it embeds are checked into `output/` directly, so this works offline against the repo
alone — no external data needed to reproduce *the manuscript*.

The underlying **analysis** is a different matter. The pipeline scripts in `scripts/` (run in numeric order,
`10_rerun_fixed.R` → `18_master_jobs.R`) regenerate those figures and tables from the DigiKat master corpus, but
that corpus contains scraped post text and is not distributed in this repository — see
[Data availability](#data-availability-and-what-is-deliberately-not-here) below. Given access to the master, the
pipeline is:

| Script | Does |
|---|---|
| `10_rerun_fixed.R` | inflation/religion tagging, linkage filter, metaphor/homonym guards → candidate pool |
| `13_make_coding_pool.R` | builds the 1,450-candidate annotation batches |
| *(external)* | 3-annotator LLM coding workflow, majority-adjudicated |
| `14_finalize_coded.R` | assembles the measured core from coded labels |
| `15_paper_analysis.R` | register / outlet / sentiment tables + Figures 1–5 |
| `16_review_response.R` | stream-conditioning, `hkm.hr` decomposition, latent-justice bound |
| `17_h1_hicp.R` | H1 test — inflation-attention vs Croatian HICP, Table 6 / Figure 6 |
| `18_master_jobs.R` | reviewer-response jobs: stream-conditioned tables, proximity-window sensitivity |

## Data availability and what is deliberately *not* here

This repo ships the **paper and its published aggregates only**. It deliberately excludes:

- **Per-post data** (URLs, headlines, text excerpts, individual coding labels). The underlying corpus is scraped
  media content; the paper's own Data Availability section holds the measured-core file "internally pending a
  statistical-disclosure review," and that policy is enforced here too — nothing at post-level granularity is
  published.
- **Reference PDFs** used during the literature review (third-party copyrighted papers) — cited in the
  manuscript's bibliography instead.
- **Superseded working drafts** and internal process notes not needed to read or reproduce this version of the
  paper.

Everything under `output/` is aggregate (counts, percentages, monthly/yearly series) and corresponds directly to
a table or figure cited by number in the paper text.

## Status

Working manuscript under revision — see [`review/REVIEW_REPORT.md`](review/REVIEW_REPORT.md) for the open
peer-review action items (autocorrelation-corrected inference, human double-coding of a validation slice, a
secular-media benchmark, and reference normalization are the main ones outstanding). Authorship and author order
are to be finalized.

## License

Manuscript text and figures: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Analysis code: MIT
(see [`LICENSE`](LICENSE)).

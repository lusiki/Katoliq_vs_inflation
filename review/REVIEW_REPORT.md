# Peer-Review Report

**Manuscript:** *Costlier Candles, Quiet Prophets: How Religion Meets Inflation in the Croatian Digital Media Space, 2021–2026*
**Author:** Luka Šikić (Catholic University of Croatia, Department of Communication Studies) — DigiKat project
**Target journal:** *Revija za socijalnu politiku / Croatian Journal of Social Policy*
**Review date:** 2 July 2026
**File reviewed:** `PAPER_v1.md`
**Review method:** four-reviewer panel on the standard journal dimensions — (A) Methods & Statistics, (B) Substantive Contribution & Theory, (C) Presentation, Structure & Journal-Fit, (D) Data, Reproducibility & Ethics — followed by cross-reviewer synthesis.

---

## 1. Editorial recommendation

**MAJOR REVISION.**

This is a genuinely original, unusually self-aware paper with a clean and transferable methodological core (the corpus-to-core "funnel" and the *linkage ≠ co-occurrence* demonstration). It is not a reject — the substantive finding is novel and the honesty about limitations is exemplary. But three classes of problem must be resolved before it is publishable: (i) the two claims the paper actually *tests* (H1 quantitatively, P3 by pattern-matching) are stated more strongly than the evidence licenses; (ii) the flagship interpretation ("Church as economic object, not moral voice") outruns what a religion-*filtered*, 85%-secular news corpus can support; and (iii) the open-science / reproducibility apparatus the paper claims for itself (FAIR, "reproducible", CC BY) is not yet backed by anything a reader can verify. All are fixable without new data collection.

## 2. Quality scores by dimension

| Dimension | Score (1–10) | One-line justification |
|---|:--:|---|
| Methodological & statistical rigor | **5** | Excellent design instinct (linkage vs co-occurrence), but the sole inferential test (H1) is uncorrected for autocorrelation and the central register measurement is low-reliability, LLM-only-validated, and not stream-conditioned. |
| Substantive contribution & theory | **6** | Novel national-scale descriptive finding, competent theory use; held back by an interpretive frame that exceeds the corpus and a "72% economic-object" construct that partly absorbs the moral voice it declares absent. |
| Presentation, structure & journal-fit | **6** | Vivid, disciplined prose now in journal house style (see §6); remaining issues are content-level presentation (abstract length, reference normalization, internal artifacts). *Was 4/10 before the house-style pass.* |
| Data, reproducibility & ethics | **4** | Exceptional candor *about* limitations, but ships no verifiable artifacts, leaves the pivotal LLM-coding step version-unpinned and undocumented, and the ethics statement is GDPR-light. |
| **Overall** | **≈5.5** | Strong, publishable idea; not yet publication-grade execution on inference, interpretation, and transparency. |

## 3. Cross-cutting issues (raised independently by ≥2 reviewers — highest priority)

These carry the most weight because multiple reviewers converged on them.

1. **"P3 disconfirmed" overclaims (Methods + Substance).** The design can only show the CST-justice frame has *low digital-news visibility*; it cannot establish that the Church is *not* a prophetic actor, because homilies, pastoral letters, and Caritas reports are structurally absent from a news-monitoring corpus, and the paper itself says visibility ≠ conduct. **Fix:** downgrade the P3 verdict everywhere (abstract, scorecard, Appendix C) to "not visible in the digital-news measure; actor-level claim not testable here."

2. **The register measurement is the load-bearing evidence yet is the weakest link (Methods + Substance + Repro).** Register agreement is only 0.46, the coefficient type is unspecified (possibly uncorrected percent agreement on skewed classes), per-category reliability for the pivotal *justice* class is unreported, and it rests on LLM annotators with no human gold standard. **Fix:** report a chance-corrected statistic (Krippendorff's α / Fleiss' κ) per axis and per category, describe the majority/tie rule, and treat the planned human double-coding as required-before-inference, not optional.

3. **The "72% economic-object macro-register" is partly a category error (Substance + Methods).** "Church-as-institution" is explicitly defined to include clergy *as commentators* — i.e. speaking subjects, some of whom voice economic/moral content — so bundling it into an "economic object" is internally inconsistent with the paper's own thesis. **Fix:** split institution-as-affected-party from clergy-as-commentator; only the former belongs in an object construct; revise the 72% accordingly.

4. **Interpretation exceeds the corpus (Substance + Methods + Presentation).** The religion-filtered, 85%-secular, 96%-web corpus measures *how secular digital media construct religion-and-inflation*, not "the Church's voice." **Fix:** reframe the title-level claim throughout as digital-public *visibility*; add media gatekeeping / newsworthiness as an explicit rival explanation to "the Church is quiet."

5. **The open-science / FAIR claim is unmet (Repro + Presentation).** No repository, DOI, released codebook, prompts, or coded file; the pipeline runs only against a private master. **Fix:** either deposit a "reproducible-from-here" tier (coded core with IDs, codebook, annotation prompts, HICP CSV, analysis scripts) with a DOI, or drop "FAIR" and state honestly what is available on request.

## 4. Detailed findings by dimension

### A. Methods & statistics

**Major.**
- **A1. H1 correlation ignores autocorrelation.** HICP annual rate of change is a 12-month trailing construct; consecutive monthly values overlap 11 months, so the effective n ≪ 39 and the reported `p < 0.001` is not credible. Report HAC/Newey–West errors or prewhiten/difference; give `r` with 95% CI and true residual df; reconcile n = 39 vs the 48 months in 2021–2024.
- **A2. The headline register distribution is pooled across the two non-comparable streams** even though temporal analysis is (correctly) not. ~143 of 520 core posts come from the low-confirmation backfill (0.21 vs 0.86). Report Table 2 for the monitoring-only subset and show the 72%/3% result is stable.
- **A3. The ±220-char recall-oriented filter (recall 0.89) may drop the justice register selectively** — structural argumentation is discursive/long-form and more likely to exceed the window, biasing the 2.9% figure downward. Run a window-sensitivity analysis (±440/±880/whole-post) or hand-audit filter false-negatives for register.
- **A4. "Inter-annotator agreement 0.97" is inter-*model* and of unstated type.** Three LLMs share training data and thus correlated errors; the coefficient may be uncorrected percent agreement on skewed axes. State which models (and whether distinct), report chance-corrected statistics, and clarify whether the held-out "precision/recall" reference labels are themselves LLM-generated (if so, the validation is partly circular).
- **A5. Register reliability of the *justice* category is effectively unknown** — on an ~36-post linked held-out slice at a 3% base rate there may be ≈1 justice post. Report per-category agreement and the effective n.
- **A6. The "≈4% threshold" contrast has no test, no bin sizes, and an imposed cutpoint.** Report months per bin, a CI / two-sample comparison, and state the breakpoint is assumed, not estimated (n = 39 cannot identify a breakpoint).
- **A7. Verdicts overstate.** H1 should be *partially* supported (the "energy ≥ headline" sub-clause fails, r = 0.44); H1 is also near-tautological except for the untested threshold nonlinearity.

**Minor.** "Media inflation-attention" is really the inflation-mention share *within a religion-filtered corpus* — qualify the generalization; report Wilson CIs on all shares (esp. justice 2.9%, n = 15); reconcile the "3/3 agreement, 518 posts" figure with register agreement 0.46 and the 12 disputed cases; document the majority/tie rule for 3 annotators over 6 categories; correct for multiple comparisons (6 correlations + threshold); validate or demote the auto-sentiment analysis (Table 5); note P4 is partly true by construction (justice = thematic by definition).

**Score: 5/10.**

### B. Substantive contribution & theory

**Major.**
- **B1. "Object not voice" overreaches given the corpus** (see cross-cutting #4). Reframe as the *digitally visible, secular-mediated* register; name the gatekeeping mechanism.
- **B2. The 72% macro-register conflates subject and object** (see cross-cutting #3).
- **B3. Excluding "foreign" inflation likely removes the justice register selectively** — CST's structural voice is characteristically *global* (Francis on global inequality, *Caritas in Veritate* on globalisation), so transnational-justice posts risk being coded "foreign" and dropped. Re-examine the 132 foreign posts for CST content, or report justice on the linked-domestic+foreign set (652) as a sensitivity check.
- **B4. Social-policy relevance is not established for THIS journal.** "Why it matters" addresses sociology of religion, media, and CST — not social policy. Add an *Implications for social policy* subsection: agenda-setting → public support for anti-poverty policy; charity register → faith-based welfare provision and the mixed economy of welfare; affordability of rites of passage for low-income households.
- **B5. P3 "disconfirmed"** (see cross-cutting #1).

**Minor (theory).** Invoke *second-level (attribute) agenda-setting* — it is the exact theory for "which register becomes salient" and is currently omitted; defend rather than assert that Iyengar's episodic/thematic "maps closely" onto charity/justice (they co-vary but are not identical); give the operational definition of a "prophetic/structural-justice" post in the main text; name the euro-changeover as a cross-sectoral media-driven confound; slightly temper the novelty of "co-occurrence ≠ engagement" (well known in corpus linguistics — the contribution is the quantified domain demonstration).

**Minor (literature — suggestions only, per author's instruction to leave the lit review intact).** For RSP's readership consider Zrinščak (religion *and* social policy), Bežovan (civil society/Caritas), van Kersbergen & Manow (*Religion, Class Coalitions, and Welfare States*), van Oorschot (deservingness); CST primary sources are thin (*Rerum Novarum*, *Populorum Progressio*, *Laudato Si'*, the *Compendium*); the "digital religion" keyword is unsupported (cite Campbell et al. or drop it).

**Score: 6/10.**

### C. Presentation, structure & journal-fit

*Note: the manuscript has now been converted to* Revija za socijalnu politiku *house style (front-matter metadata block; single-italic abstract with no "Abstract" heading; bold Keywords; ALL-CAPS unnumbered headings with bold sentence-case subheadings; `Table N` / `Figure N` + italic caption + `Source:` notes; Acknowledgments folding funding; and a full Croatian **Sažetak**). The structural-conformance findings below that are already resolved are marked ✓; the rest remain open.*

**Resolved by the house-style pass.** ✓ Sažetak added; ✓ front-matter metadata + corresponding-author footnote; ✓ italic abstract, no heading; ✓ ALL-CAPS unnumbered headings; ✓ §-cross-references replaced with named references; ✓ Table/Figure caption convention; ✓ Table 4's overloaded caption moved to a `Note:`; ✓ math glyph ("≠") removed from the section heading.

**Still open — major.**
- **C1. Abstract length.** ~300+ words against the journal norm of ~150–180. Cut roughly in half: keep the funnel (710,307 → 520), the ≈72% / 3% result, and the H1/P3/P4 verdicts; drop numeric asides (2.4-fold, per-component r, the ≈8% bound).
- **C2. "Limitations" and "Methodological contribution" remain standalone top-level sections.** RSP's own papers fold limitations into the Discussion; consider folding both (the methodological point is already previewed in Results/Discussion).
- **C3. Reference list not yet normalized to RSP style** (italic journal title *and* volume; DOIs as full URLs; full author lists — e.g. Champagne "et al."; publisher/place for encyclicals). Flagged by the author as a deferred to-do; must be completed before submission.

**Still open — minor.** Table citation order (Table 3 cited in "Who carries it" before Table 2 in the next subsection); uncited references in the list (Geiß 2022, Gutiérrez 1971/1973, Lamla & Maag 2012 — cite or remove); internal artifacts in prose (`original_dta`, `filtered_religious`, `data_source`; and Appendix pointers to `CLAUDE.local.md`, `VALIDATION.md`, `REVIEW_RESPONSE.md`, `LITERATURE.md` — gloss or mark "available on request"); UDK/doi/Received are placeholders (journal-assigned — expected); acronym/jargon density (CST, HICP, macro-register, held-out precision) — gloss on first use for a social-policy audience; figure filename prefixes inconsistent (`fig_` vs `coded_`); seven keywords (trim to ~5); the bare "Costlier candles, quiet prophets." sentence in the Conclusion is slightly informal. **Positive:** all table totals reconcile to 520 and headline figures agree across abstract/results/discussion/appendix — no numeric inconsistencies found.

**Score: 6/10** (was 4/10 on the pre-conversion draft).

### D. Data, reproducibility & ethics

**Major.**
- **D1. FAIR / open-science claim unsubstantiated** (see cross-cutting #5). Deposit a verifiable tier with a DOI, or drop the claim.
- **D2. LLM annotators undocumented → central step not reproducible.** Missing: model name + exact version/snapshot, provider, temperature/decoding params, verbatim prompts + codebook, run dates, whether three distinct models or one model sampled three times, and the adjudication rule. Add a subsection (or expand Appendix B) supplying all of these and archive raw per-annotator labels with post IDs.
- **D3. LLM-coding fragility under-acknowledged.** Re-running the prompts against an updated model can change the core and the headline percentages; reproducibility is via the *frozen label file*, not by re-running the model. State this and temper the "reusable template" claim.
- **D4. Nothing reproduces end-to-end for an external reader.** Define a master-independent tier: coded core with stable IDs + label columns for Tables 2–5/Figures 1–5; HICP CSV + `17_h1_hicp.R` so Table 6/Figure 6 are fully reproducible; codebook + prompts; a README mapping each table/figure to script + input; pin R/package versions (`renv`/`sessionInfo`).
- **D5. Ethics statement GDPR-light.** "Publicly posted" is not a GDPR exemption. State the legal basis (research/statistical processing under Art. 6/89 + Croatian implementing act), whether an institutional ethics / data-protection sign-off exists, the master's storage/access/retention, and the concrete PII-screen method; confirm the monitoring vendor's terms permit research use and redistribution of derived aggregates and of the sentiment labels.

**Minor.** Add explicit Funding and Competing-Interests statements (warranted given a Catholic-university host studying the Catholic Church — disclose the relationship and affirm analytical independence); confirm outlet names are reported as public-record publishers with no individual-level attribution; name the sentiment vendor/tool or flag Table 5 as exploratory; verify all references and add DOIs, then remove the in-text "remain to be verified … `LITERATURE.md`" note; give a custodian/procedure/timeline for the internally-held measured-core file; add repository/DOI placeholders and (for the planned human coding / secular benchmark) a pre-registration pointer; document the post-ID scheme in the codebook.

**Score: 4/10.**

## 5. Prioritized action list (before resubmission)

**Must-fix (blocks acceptance):**
1. Re-state P3 as a *visibility* result, not "disconfirmed"; propagate to abstract, scorecard, Appendix C. *(cross-cutting #1)*
2. Report chance-corrected reliability per axis and per category; commit the human double-coding of register + the foreign/domestic boundary. *(A4, A5, cross-cutting #2)*
3. Correct the H1 inference for autocorrelation; add CIs, bin sizes, and honest threshold caveats; change verdict to *partially supported*. *(A1, A6, A7)*
4. Show the 72%/3% result holds monitoring-stream-only and is not a subject/object conflation. *(A2, B2, cross-cutting #3)*
5. Reframe the corpus-scope interpretation and add the gatekeeping rival explanation. *(B1, cross-cutting #4)*
6. Document the LLM-coding procedure and deposit a reproducible tier + codebook + prompts; align or drop the FAIR claim. *(D1–D4, cross-cutting #5)*
7. Add a legal-basis / ethics-sign-off paragraph and vendor-terms confirmation. *(D5)*

**Should-fix (materially strengthens):**
8. Add an *Implications for social policy* subsection. *(B4)*
9. Test justice against the ±window and against the foreign-inflation set. *(A3, B3)*
10. Trim the abstract to ~180 words; normalize references to RSP style; remove internal artifacts and the verification note. *(C1, C3, minors)*

**Nice-to-have:** second-level agenda-setting; validate or demote sentiment; RSP-relevant citations (Zrinščak, Bežovan) and CST primary sources; fold Limitations into Discussion; trim keywords.

## 6. Note on manuscript state

The reviewers evaluated the working manuscript as it then stood. The paper has since been reformatted to *Revija za socijalnu politiku* house style (metadata block, italic abstract, ALL-CAPS headings, journal table/figure captions, Acknowledgments, and a Croatian Sažetak). The presentation findings in §4.C are reconciled to that transformed file: resolved items are marked ✓, and only the genuinely outstanding presentation items are listed as open. The methodological, substantive, and reproducibility findings are independent of formatting and stand in full.

---

*Report compiled from a four-reviewer panel (Methods & Statistics; Substantive/Domain; Presentation & Journal-Fit; Data, Reproducibility & Ethics). Scores are indicative reviewer judgments, not journal decisions.*

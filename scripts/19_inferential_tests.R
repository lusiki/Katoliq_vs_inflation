## 19_inferential_tests.R — the three formal hypothesis tests reported in the paper (Table 7).
## Reproducible from the published aggregate tables in output/ (no master corpus needed).
## Needs base R only. Run from the study root.
OUT <- "../output"          # adjust to "output" if running from the repo
if (!dir.exists(OUT)) OUT <- "output"
cramer_v <- function(chisq, n, r, c) sqrt(as.numeric(chisq) / (n * min(r - 1, c - 1)))

## ---------- H2: register composition depends on outlet type ----------
## Validated coded data. Secular vs Catholic (the 3 business-press posts are dropped;
## the small 'disputed'/'other' rows are pooled into 'Other'). Cells are sparse, so we
## confirm the asymptotic chi-square with a Monte Carlo test.
t3 <- read.csv(file.path(OUT, "tables/t3_register_by_outlet.csv"), check.names = FALSE, fileEncoding = "UTF-8-BOM")
rownames(t3) <- t3$register
sc <- as.matrix(t3[, c("Secular/other", "Catholic")])
keep <- c("Cost of religious life", "Church-as-institution", "Charity/relief", "Devotional", "Structural/CST justice")
m2 <- rbind(sc[keep, ], Other = colSums(sc[!rownames(sc) %in% keep, , drop = FALSE]))
h2  <- suppressWarnings(chisq.test(m2))
h2mc <- chisq.test(m2, simulate.p.value = TRUE, B = 20000)
cat(sprintf("H2 register x outlet:  X2 = %.1f, df = %d, asymptotic p = %.3g, Monte Carlo p = %.5f, Cramer's V = %.3f\n",
            h2$statistic, h2$parameter, h2$p.value, h2mc$p.value, cramer_v(h2$statistic, sum(m2), nrow(m2), ncol(m2))))

## ---------- H3: tone depends on register (vendor sentiment labels, exploratory) ----------
t5 <- read.csv(file.path(OUT, "tables/t5_sentiment_by_register.csv"), check.names = FALSE, fileEncoding = "UTF-8-BOM")
rownames(t5) <- t5$register
m3 <- as.matrix(t5[keep, c("negative", "neutral", "positive")])
h3 <- suppressWarnings(chisq.test(m3))
cat(sprintf("H3 tone x register:    X2 = %.1f, df = %d, p = %.3g, Cramer's V = %.3f\n",
            h3$statistic, h3$parameter, h3$p.value, cramer_v(h3$statistic, sum(m3), nrow(m3), ncol(m3))))

## ---------- H1: attention below vs at/above the ~4% HICP threshold ----------
h1path <- file.path(OUT, "h1_attention_hicp_series.csv")
if (!file.exists(h1path)) h1path <- file.path(OUT, "tables", "h1_attention_hicp_series.csv")
h <- read.csv(h1path, fileEncoding = "UTF-8-BOM")
h$hi <- h$hicp_headline >= 4
tt <- t.test(share ~ hi, data = h)                  # Welch two-sample
g1 <- h$share[!h$hi]; g2 <- h$share[h$hi]
sp <- sqrt(((length(g1) - 1) * var(g1) + (length(g2) - 1) * var(g2)) / (length(g1) + length(g2) - 2))
cat(sprintf("H1 threshold contrast: mean %.2f (n=%d, <4%%) vs %.2f (n=%d, >=4%%), Welch t = %.2f, p = %.3g, Cohen's d = %.2f\n",
            mean(g1), length(g1), mean(g2), length(g2), tt$statistic, tt$p.value, (mean(g2) - mean(g1)) / sp))
cat(sprintf("H1 correlation (context): Pearson r = %.2f with headline HICP\n", cor(h$share, h$hicp_headline)))
cat("\nNOTE: the H1 months are autocorrelated (12-month HICP construct), so H1 p-values are descriptive.\n")

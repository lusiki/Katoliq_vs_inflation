## H1: does inflation ATTENTION track real HICP? Tested WITHIN the clean 2021-2024 stream.
suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
HAS_GG <- requireNamespace("ggplot2", quietly=TRUE)
opt <- stri_opts_regex(case_insensitive=TRUE)
ci <- function(re,x) stri_detect_regex(x, re, opts_regex=opt) %in% TRUE
OUT <- "studies/inflation-salience/output"
infl_re <- paste0("inflacij|poskup|deflacij|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|kriza troškova|cijene rastu|cijene skaču")

cat("Loading master ...\n"); flush.console()
dt <- as.data.table(readRDS("data/merged_comprehensive.rds"))
dt[, month := substr(DATE,1,7)]
dt[, infl := ci(infl_re, paste(ifelse(is.na(TITLE),"",TITLE), ifelse(is.na(FULL_TEXT),"",FULL_TEXT)))]

## monthly attention by stream
att <- dt[!is.na(month) & month>="2021-01", .(n_total=.N, n_infl=sum(infl)), by=.(month, data_source)]
att[, share := 100*n_infl/n_total]
## overall (both streams pooled)
attall <- dt[!is.na(month) & month>="2021-01", .(n_total=.N, n_infl=sum(infl)), by=month][order(month)]
attall[, share := 100*n_infl/n_total]

hicp <- fread(file.path(OUT,"hicp_hr.csv"))
orig <- merge(att[data_source=="original_dta"], hicp, by="month")[order(month)]
poolm <- merge(attall, hicp, by="month")[order(month)]

cat(sprintf("\noriginal_dta stream months with HICP: %d (%s .. %s)\n", nrow(orig), min(orig$month), max(orig$month)))
cat(sprintf("pooled months with HICP: %d\n", nrow(poolm)))

corr <- function(x, y, lab){
  pr <- suppressWarnings(cor(x,y,method="pearson")); sp <- suppressWarnings(cor(x,y,method="spearman"))
  ct <- suppressWarnings(cor.test(x,y,method="pearson"))
  cat(sprintf("  %-34s Pearson r=%.2f (p=%.4f, n=%d)  Spearman rho=%.2f\n", lab, pr, ct$p.value, length(x), sp))
}
cat("\n=== H1 — WITHIN original_dta stream (clean 2021-2024 window) ===\n")
cat("Inflation-attention share (%) vs HICP annual rate:\n")
corr(orig$share, orig$hicp_headline, "attention ~ HICP headline")
corr(orig$share, orig$hicp_food,     "attention ~ HICP food")
corr(orig$share, orig$hicp_energy,   "attention ~ HICP energy")

cat("\n=== Pooled 2021-2025 (BATCH-CONFOUNDED at 2024 seam — reported for completeness) ===\n")
corr(poolm$share, poolm$hicp_headline, "attention ~ HICP headline")
corr(poolm$share, poolm$hicp_food,     "attention ~ HICP food")
corr(poolm$share, poolm$hicp_energy,   "attention ~ HICP energy")

cat("\n=== Attention-threshold check (Korenok/Pfäuti ~4%), within original_dta ===\n")
orig[, hi := hicp_headline >= 4]
print(orig[, .(months=.N, mean_attention=round(mean(share),2)), by=hi][order(hi)])
cat(sprintf("attention above vs below 4%% headline HICP: %.2f%% vs %.2f%%\n",
            orig[hi==TRUE, mean(share)], orig[hi==FALSE, mean(share)]))

## linked core (religion-specific) annual vs annual mean HICP
core <- as.data.table(readRDS(file.path(OUT,"analysis_core_coded.rds")))
core[, yr := as.integer(year)]
hicp[, yr := as.integer(substr(month,1,4))]
cyr <- core[, .(core_posts=.N), by=yr][order(yr)]
hyr <- hicp[, .(hicp_headline=round(mean(hicp_headline),1), hicp_food=round(mean(hicp_food),1)), by=yr]
cat("\n=== Religion-linked CORE (annual) vs mean HICP ===\n")
print(merge(cyr, hyr, by="yr", all.x=TRUE))
cat("(core monthly is too sparse for correlation; annual alignment only. Note 2024+ core spans the batch seam.)\n")

## figure: attention (original_dta) + HICP
if (HAS_GG) { library(ggplot2)
  orig[, mdate := as.Date(paste0(month,"-01"))]
  sc <- max(orig$hicp_food)/max(orig$share)
  png(file.path(OUT,"h1_attention_vs_hicp.png"), width=1150, height=600, res=120)
  print(ggplot(orig, aes(mdate)) +
    geom_col(aes(y=share), fill="#8B2E2E", alpha=0.35) +
    geom_line(aes(y=hicp_headline/sc, color="HICP headline"), linewidth=0.9) +
    geom_line(aes(y=hicp_food/sc, color="HICP food"), linewidth=0.9) +
    geom_line(aes(y=hicp_energy/sc, color="HICP energy"), linewidth=0.7, linetype="dashed") +
    scale_y_continuous(name="Inflation-attention share (% of posts, bars)",
                       sec.axis=sec_axis(~.*sc, name="HICP annual rate (%)")) +
    scale_color_manual(values=c("HICP headline"="#2E5E8B","HICP food"="#C9A227","HICP energy"="#2E8B57"), name=NULL) +
    labs(title="H1: media inflation-attention vs real HICP (2021–2024 monitoring stream)",
         subtitle="Bars = share of corpus posts mentioning inflation (original_dta stream); lines = Croatian HICP (Eurostat).",
         x=NULL) + theme_minimal(base_size=12) + theme(legend.position="top"))
  dev.off(); cat("\nFig: h1_attention_vs_hicp.png\n")
}
fwrite(orig[, .(month, n_total, n_infl, share, hicp_headline, hicp_food, hicp_energy)], file.path(OUT,"h1_attention_hicp_series.csv"), bom=TRUE)
cat("\nDONE h1\n")

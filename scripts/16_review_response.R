## Address reviewer criticisms with data: C1 stream confound, C2 hkm decomposition,
## C3a latent-justice upper bound, M1 macro-register, M2 high-confidence subset, m1/m3 coverage/platform.
suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
opt <- stri_opts_regex(case_insensitive=TRUE)
OUT <- "studies/inflation-salience/output"
core <- as.data.table(readRDS(file.path(OUT,"analysis_core_coded.rds")))
pool <- fread(file.path(OUT,"coded_pool_full.csv"), colClasses=list(character="rid"))
pool[, rid := as.integer(rid)]; core[, rid := as.integer(rid)]
pool[, yr := substr(DATE,1,4)]

cat("Loading master for data_source join ...\n"); flush.console()
dt <- as.data.table(readRDS("data/merged_comprehensive.rds"))
dt[, rid := .I]
ds <- dt[, .(rid, data_source)]
core <- merge(core, ds, by="rid", all.x=TRUE)
pool <- merge(pool, ds, by="rid", all.x=TRUE)

cat("\n############ C1 — TEMPORAL vs BATCH (data_source) ############\n")
cat("\ndata_source coverage of the coded core:\n"); print(core[, .N, by=data_source])
cat("\nCore volume by year x data_source:\n")
print(dcast(core[, .N, by=.(year, data_source)], year ~ data_source, value.var="N", fill=0))
cat("\nPer-year confirmation rate (domestic core / candidates), by stream:\n")
cand <- pool[, .(cand=.N), by=.(yr, data_source)]
dom  <- pool[domestic==1, .(dom=.N), by=.(yr, data_source)]
cr <- merge(cand, dom, by=c("yr","data_source"), all=TRUE); cr[is.na(dom), dom:=0]
cr[, rate := round(dom/cand,2)]; print(cr[order(data_source, yr)])
cat("\n=> WITHIN original_dta (2021-2024) core volume by year (clean temporal window):\n")
print(core[data_source=="original_dta", .N, by=year][order(year)])
cat("=> WITHIN filtered_religious (2024-2026):\n")
print(core[data_source=="filtered_religious", .N, by=year][order(year)])

cat("\n############ C2 — CATHOLIC subsample / hkm.hr dependence ############\n")
cath <- core[otype=="Catholic"]
cat(sprintf("Catholic core n=%d; hkm.hr=%d (%.0f%%)\n", nrow(cath), sum(cath$FROM=="hkm.hr"), 100*mean(cath$FROM=="hkm.hr")))
cat("\nCatholic register WITH hkm.hr:\n"); print(cath[, .N, by=register][order(-N)])
cat("\nhkm.hr register breakdown:\n"); print(cath[FROM=="hkm.hr", .N, by=register][order(-N)])
cat("\nCatholic register WITHOUT hkm.hr (effective n):\n"); print(cath[FROM!="hkm.hr", .N, by=register][order(-N)])

cat("\n############ C3a — LATENT justice upper bound ############\n")
struct_re <- "nepravd|nepravedn|siromaš|siroma|nejednakost|preraspodjel|dostojanstv|izrabljiv|iskorištav|ranjiv|social(n|ne) pravd|preferencijaln|ekonomija ubija|struktur"
core[, lat_struct := stri_detect_regex(window, struct_re, opts_regex=opt) %in% TRUE]
cat(sprintf("strict justice: %d (%.1f%%)\n", sum(core$register=="justice"), 100*mean(core$register=="justice")))
cat("posts in OTHER registers whose window contains structural language (latent-justice candidates):\n")
print(core[register!="justice" & lat_struct==TRUE, .N, by=register][order(-N)])
ub <- sum(core$register=="justice") + sum(core$register!="justice" & core$lat_struct)
cat(sprintf("=> justice UPPER BOUND (strict + latent) = %d (%.1f%%)\n", ub, 100*ub/nrow(core)))

cat("\n############ M1 — macro-register (economic object) ############\n")
cat(sprintf("cost_relig_life + institution = %d (%.1f%%)  [the robust combined claim]\n",
  sum(core$register %in% c("cost_relig_life","institution")), 100*mean(core$register %in% c("cost_relig_life","institution"))))

cat("\n############ M2 / m1 — annotator coverage & high-confidence subset ############\n")
cat("n_ann distribution (whole pool):\n"); print(pool[, .N, by=n_ann][order(-n_ann)])
cat(sprintf("Core with 3/3 annotators: %d of %d\n", sum(pool[domestic==1]$n_ann==3), nrow(core)))

cat("\n############ m3 — platform of core ############\n")
print(core[, .(n=.N, pct=round(100*.N/nrow(core),1)), by=SOURCE_TYPE][order(-n)])

## figure: stream-split temporal (C1)
if (requireNamespace("ggplot2", quietly=TRUE)) { library(ggplot2)
  core[, mdate := as.Date(paste0(substr(DATE,1,7),"-01"))]
  m <- core[!is.na(mdate), .N, by=.(mdate, data_source)]
  png(file.path(OUT,"coded_core_by_stream.png"), width=1150, height=520, res=120)
  print(ggplot(m, aes(mdate, N, fill=data_source)) + geom_col() +
    scale_fill_manual(values=c(original_dta="#2E5E8B", filtered_religious="#C9A227"), name="Collection stream") +
    labs(title="Measured core volume by collection stream (batch confound check)",
         subtitle="original_dta ≈2021–2024 monitoring; filtered_religious ≈2024–2026 backfill. Trends must be read within-stream.",
         x=NULL, y="Posts/month") + theme_minimal(base_size=12) + theme(legend.position="top"))
  dev.off(); cat("\nFig: coded_core_by_stream.png\n")
}
cat("\nDONE review_response\n")

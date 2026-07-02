## Finalize: parse coded labels -> join to pool -> measured core + numbers + figures.
suppressWarnings(suppressMessages({ library(data.table); library(jsonlite); library(stringi) }))
HAS_GG <- requireNamespace("ggplot2", quietly = TRUE)
OUT <- "studies/inflation-salience/output"
OUTF <- "scratch/annotation_run.output"  # JSON output of the 3-annotator LLM coding workflow (external step; see README)

J <- fromJSON(OUTF, simplifyDataFrame=TRUE)
maj <- as.data.table(J$result$majority)
cat(sprintf("Workflow summary: coded=%d infl=%d link=%d domestic=%d\n",
            J$result$n_coded, J$result$n_infl, J$result$n_link, J$result$n_domestic))
fwrite(maj, file.path(OUT,"coded_labels.csv"), bom=TRUE)

pool <- as.data.table(readRDS(file.path(OUT,"coding_pool.rds")))
cat(sprintf("Pool=%d  coded=%d\n", nrow(pool), nrow(maj)))
miss <- setdiff(pool$rid, maj$rid)
cat(sprintf("Coverage: %d/%d coded; %d MISSING; %d with n<3\n",
            nrow(maj), nrow(pool), length(miss), sum(maj$n<3)))
if (length(miss)>0) cat("  missing rids (first 20):", paste(head(miss,20),collapse=","), "\n")

d <- merge(pool, maj[, .(rid, c_infl=infl, c_link=link, c_foreign=foreign, c_register=register, n_ann=n)], by="rid", all.x=TRUE)
d[, domestic := as.integer(c_infl==1 & c_link==1 & c_foreign==0)]

cat("\n=== MEASURED RESULTS on the coded pool (n candidates =", nrow(d), ") ===\n")
cat(sprintf("confirmed inflation: %d (%.0f%% of candidates)\n", sum(d$c_infl==1,na.rm=TRUE), 100*mean(d$c_infl==1,na.rm=TRUE)))
cat(sprintf("confirmed religion-linked: %d\n", sum(d$c_infl==1 & d$c_link==1, na.rm=TRUE)))
cat(sprintf("  of which FOREIGN: %d ; DOMESTIC: %d\n",
            sum(d$c_infl==1 & d$c_link==1 & d$c_foreign==1, na.rm=TRUE), sum(d$domestic==1, na.rm=TRUE)))

core <- d[domestic==1]
cat(sprintf("\n=== MEASURED DOMESTIC CORE: %d posts ===\n", nrow(core)))
cat("\nRegister distribution:\n"); print(core[, .(n=.N, pct=round(100*.N/nrow(core),1)), by=c_register][order(-n)])
cat("\nBy outlet type:\n"); print(core[, .N, by=otype][order(-N)])
cat("\nBy year:\n"); print(core[, .N, by=year][order(year)])
cat("\nRegister × year:\n"); print(dcast(core[, .N, by=.(year, c_register)], year ~ c_register, value.var="N", fill=0))

## recall-corrected full estimate (linkage recall ~0.89 on the pool)
cat(sprintf("\nRecall note: pool linkage recall ≈0.89 -> est. TRUE domestic core ≈ %.0f (core/0.89)\n", nrow(core)/0.89))

## save measured core
core_out <- core[, .(rid, DATE, year, FROM, SOURCE_TYPE, otype, register=c_register, AUTO_SENTIMENT, URL, TITLE, window=ctx)]
saveRDS(core_out, file.path(OUT,"analysis_core_coded.rds"))
fwrite(core_out, file.path(OUT,"analysis_core_coded.csv"), bom=TRUE)
fwrite(d[, .(rid, DATE, FROM, otype, c_infl, c_link, c_foreign, c_register, domestic, n_ann)], file.path(OUT,"coded_pool_full.csv"), bom=TRUE)
cat("\nSaved analysis_core_coded.{rds,csv} (measured core) + coded_pool_full.csv\n")

## figures
core[, mdate := as.Date(paste0(substr(DATE,1,7),"-01"))]
if (HAS_GG) { library(ggplot2)
  reg_levels <- c("cost_relig_life","institution","charity","justice","devotional","other","disputed")
  pal <- c(cost_relig_life="#C9A227", institution="#2E5E8B", charity="#2E8B57", justice="#8B2E2E", devotional="#9A6FB0", other="#999999", disputed="#cccccc")
  m <- core[!is.na(mdate), .N, by=.(mdate, c_register)]
  png(file.path(OUT,"coded_register_over_time.png"), width=1150, height=580, res=120)
  print(ggplot(m, aes(mdate, N, fill=factor(c_register, levels=reg_levels))) + geom_col() +
    scale_fill_manual(values=pal, name="Registar") +
    labs(title="Izmjereni korpus: religija × domaća inflacija — registar kroz vrijeme",
         subtitle=sprintf("%d kodiranih objava (3 anotatora, većina). Mjesečno.", nrow(core)),
         x=NULL, y="Broj objava") + theme_minimal(base_size=12) + theme(legend.position="top"))
  dev.off()
  yr <- core[year %in% as.character(2021:2026), .N, by=.(year, c_register)]
  png(file.path(OUT,"coded_register_by_year.png"), width=1150, height=560, res=120)
  print(ggplot(yr, aes(year, N, fill=factor(c_register, levels=reg_levels))) + geom_col() +
    scale_fill_manual(values=pal, name="Registar") +
    labs(title="Izmjereni korpus: registar po godini", x=NULL, y="Broj objava") + theme_minimal(base_size=12))
  dev.off()
  cat("Figures: coded_register_over_time.png, coded_register_by_year.png\n")
}
cat("\nDONE finalize\n")

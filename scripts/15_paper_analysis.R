## Paper analysis: all tables + figures from the coded measured core.
suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
HAS_GG <- requireNamespace("ggplot2", quietly = TRUE)
OUT <- "studies/inflation-salience/output"
TAB <- file.path(OUT, "tables"); dir.create(TAB, showWarnings=FALSE, recursive=TRUE)
core <- as.data.table(readRDS(file.path(OUT,"analysis_core_coded.rds")))
pool <- fread(file.path(OUT,"coded_pool_full.csv"), colClasses=list(character="rid"))
reg_lab <- c(cost_relig_life="Cost of religious life", institution="Church-as-institution",
             charity="Charity/relief", devotional="Devotional", justice="Structural/CST justice",
             other="Other", disputed="Disputed")
N_CORPUS <- 710307L; N_INFL_RAW <- 8105L; N_INFL_CLEAN <- 8019L; N_LINK_CAND <- 1450L

cat("================ TABLE 1: FUNNEL ================\n")
funnel <- data.table(
  stage = c("Full religion-filtered corpus","Mentions inflation (raw tag)","… clean (metaphors removed)",
            "Linked candidates (regex, recall~0.89)","Confirmed religion-linked (coded)",
            "  … foreign inflation","  … DOMESTIC (measured core)"),
  n = c(N_CORPUS, N_INFL_RAW, N_INFL_CLEAN, N_LINK_CAND,
        sum(pool$c_infl==1 & pool$c_link==1, na.rm=TRUE),
        sum(pool$c_infl==1 & pool$c_link==1 & pool$c_foreign==1, na.rm=TRUE),
        nrow(core)))
funnel[, pct_of_corpus := round(100*n/N_CORPUS, 3)]
print(funnel); fwrite(funnel, file.path(TAB,"t1_funnel.csv"), bom=TRUE)

cat("\n================ TABLE 2: REGISTER (measured core, n=520) ================\n")
t2 <- core[, .(n=.N), by=register][order(-n)]; t2[, pct := round(100*n/sum(n),1)]
t2[, label := reg_lab[register]]; print(t2[, .(register=label, n, pct)]); fwrite(t2, file.path(TAB,"t2_register.csv"), bom=TRUE)

cat("\n================ TABLE 3: REGISTER x OUTLET TYPE ================\n")
t3 <- dcast(core[, .N, by=.(otype, register)], register ~ otype, value.var="N", fill=0)
t3[, register := reg_lab[register]]; print(t3); fwrite(t3, file.path(TAB,"t3_register_by_outlet.csv"), bom=TRUE)
cat("\nOutlet-type totals in core:\n"); print(core[, .(n=.N, pct=round(100*.N/nrow(core),1)), by=otype][order(-n)])

cat("\n================ TABLE 4: REGISTER x YEAR ================\n")
t4 <- dcast(core[, .N, by=.(year, register)], year ~ register, value.var="N", fill=0)
print(t4); fwrite(t4, file.path(TAB,"t4_register_by_year.csv"), bom=TRUE)
cat("\nCore volume by year:\n"); print(core[, .(n=.N), by=year][order(year)])

cat("\n================ TABLE 5: SENTIMENT x REGISTER ================\n")
core[, sent := fifelse(is.na(AUTO_SENTIMENT)|AUTO_SENTIMENT=="","undefined", AUTO_SENTIMENT)]
t5 <- dcast(core[, .N, by=.(register, sent)], register ~ sent, value.var="N", fill=0)
t5[, register := reg_lab[register]]; print(t5); fwrite(t5, file.path(TAB,"t5_sentiment_by_register.csv"), bom=TRUE)
cat("\nOverall sentiment of core:\n"); print(core[, .(n=.N, pct=round(100*.N/nrow(core),1)), by=sent][order(-n)])

cat("\n================ TABLE 6: TOP OUTLETS in core ================\n")
t6 <- core[!is.na(FROM), .(n=.N), by=FROM][order(-n)][1:15]
print(t6); fwrite(core[!is.na(FROM), .(n=.N, top_register=names(sort(table(register),decreasing=TRUE))[1]), by=FROM][order(-n)], file.path(TAB,"t6_top_outlets.csv"), bom=TRUE)

## classifier precision by dimension (from coded pool) for the methods section
cat("\n================ Methods: coded-pool confirmation rates ================\n")
cat(sprintf("candidates=%d | confirmed inflation=%.1f%% | confirmed linked (of all cand)=%.1f%% | domestic (of all cand)=%.1f%%\n",
  nrow(pool), 100*mean(pool$c_infl==1,na.rm=TRUE), 100*mean(pool$c_link==1 & pool$c_infl==1,na.rm=TRUE),
  100*mean(pool$domestic==1,na.rm=TRUE)))

## ---------- FIGURES ----------
if (HAS_GG) { library(ggplot2)
  pal <- c(`Cost of religious life`="#C9A227",`Church-as-institution`="#2E5E8B",`Charity/relief`="#2E8B57",
           `Structural/CST justice`="#8B2E2E",`Devotional`="#9A6FB0",`Other`="#999999",`Disputed`="#cccccc")
  core[, reglab := factor(reg_lab[register], levels=names(pal))]
  # Fig A: register composition
  fa <- core[, .(n=.N), by=reglab][order(-n)]
  png(file.path(OUT,"fig_register_composition.png"), width=1000, height=560, res=120)
  print(ggplot(fa, aes(reorder(reglab,n), n, fill=reglab)) + geom_col(show.legend=FALSE) + coord_flip() +
    scale_fill_manual(values=pal) + geom_text(aes(label=sprintf("%d (%.0f%%)",n,100*n/sum(fa$n))), hjust=-0.1, size=3.5) +
    labs(title="Register of domestic religion×inflation discourse (measured, n=520)", x=NULL, y="Posts") +
    expand_limits(y=max(fa$n)*1.15) + theme_minimal(base_size=12))
  dev.off()
  # Fig B: register by outlet type (share)
  fb <- core[, .N, by=.(otype, reglab)]
  png(file.path(OUT,"fig_register_by_outlet.png"), width=1050, height=560, res=120)
  print(ggplot(fb, aes(otype, N, fill=reglab)) + geom_col(position="fill") + scale_fill_manual(values=pal, name="Register") +
    scale_y_continuous(labels=scales::percent) + labs(title="Register composition by outlet type", x=NULL, y="Share") +
    theme_minimal(base_size=12))
  dev.off()
  # Fig C: sentiment by register (share)
  sc <- c(positive="#2E8B57", neutral="#B0B0B0", negative="#8B2E2E", undefined="#e0e0e0")
  fc <- core[, .N, by=.(reglab, sent)]
  png(file.path(OUT,"fig_sentiment_by_register.png"), width=1050, height=560, res=120)
  print(ggplot(fc, aes(reglab, N, fill=factor(sent, levels=names(sc)))) + geom_col(position="fill") +
    scale_fill_manual(values=sc, name="Auto-sentiment") + scale_y_continuous(labels=scales::percent) +
    coord_flip() + labs(title="Auto-sentiment by register (vendor labels; indicative)", x=NULL, y="Share") + theme_minimal(base_size=12))
  dev.off()
  cat("\nFigures: fig_register_composition.png, fig_register_by_outlet.png, fig_sentiment_by_register.png\n")
}
cat("\nDONE paper_analysis\n")

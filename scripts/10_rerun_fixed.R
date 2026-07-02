## FIXED rerun (validation fixes 1-5) + analysis-ready core + held-out sample + rescore-on-90.
suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
HAS_GG <- requireNamespace("ggplot2", quietly = TRUE)
opt <- stri_opts_regex(case_insensitive = TRUE)
ci <- function(re, x) stri_detect_regex(x, re, opts_regex = opt) %in% TRUE
OUT <- "studies/inflation-salience/output"; dir.create(OUT, showWarnings=FALSE, recursive=TRUE)
SCR <- "scratch"  # local working dir for intermediate text dumps
dir.create(SCR, showWarnings = FALSE, recursive = TRUE)

## ---------- religion lexicon: project base + v07 tightening + NEW: drop trapist ----------
rt <- source("R/religious_terms.R", echo = FALSE)$value
fixreg <- c(gospa="\\bgosp(a|e|i|u|om)\\b|\\bgospin", demon="\\bdemon(a|i|e|u|om|ima)?\\b|demonsk",
            papa="\\bpap(a|e|i|u|om)\\b|papin|sveti otac", misa="\\bmis(a|e|i|u|om|ama)\\b|misn[aeiou]",
            kapitul="\\bkapitul(a|u|om|i|e)?\\b")
for (tm in names(fixreg)) rt$regex[rt$term == tm] <- fixreg[[tm]]
rel_old <- paste(rt$regex, collapse="|")                  # for reproducing the OLD 90-sample strata
rt_new <- rt[rt$term != "trapist", ]                       # FIX 3b: drop trapist (cheese collision)
rel_new <- paste(rt_new$regex, collapse="|")

## ---------- inflation + metaphor guard (FIX 1) ----------
infl_re <- paste0("inflacij|poskup|deflacij|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|kriza troškova|cijene rastu|cijene skaču")
econ_anchor <- paste0("poskup|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|",
  "kriza troškova|cijene rastu|cijene skaču|antiinflacij|inflatorn|inflacijsk[ie] (pritisc|mjer|kretanj)")
infl_meta <- paste0("(hiper|de)?inflacij[a-zšđčćž]*\\s+(?:[a-zšđčćž]+\\s+){0,2}",
  "(riječ|vrijednost|vrednot|pojm|pojam|superlativ|mučenik|osjećaj|titul|diplom|emocij|sadržaj|informacij|fašiz|znanj|straha|nada\\b|nade\\b)")

## ---------- foreign gazetteer (FIX 2: tight adjacency + title + expanded) ----------
foreign_gaz <- paste0("iran|teheran|trump|biden|putin|moskv|kremlj|rusij|rusk[aeio]|ukrajin|venezuel|argentin|",
  "zimbabve|washington|bijel[ae] kuć|wall street|\\bfed\\b|federaln[ae] rezerv|amerik|američk|sjedinjen[ie] držav|",
  "njemačk|berlin|austrij|\\bbeč\\b|mađarsk|budimpešt|\\bsrbij|beograd|tursk[aeoi]|ankar|britanij|\\bengles|london|",
  "ujedinjen[oa] kraljevstv|dubai|panam|egipt|izrael|\\bgaz[ai]|sirij|libanon|grčk|atena|italij|\\brim\\b|talijan|",
  "španjolsk|francusk|pariz|bliskom istoku|\\bkina\\b|kinesk|japan|indij|poljsk|slovenij|grčk")

## ---------- register detectors ----------
charity_re <- "caritas|milostinj|humanitar|donacij|donir|dobrotvor|potrebit|pučka kuhinj|paket[a-zšđčćž]{0,3} pomoć|volonter|darivanj|zbrinjav|prikuplja[a-zšđčćž]{0,3} pomoć"
struct_re  <- "nepravd|nepravedn|siromaš|preferencijaln|ekonomija ubija|nejednakost|strukturn|izrabljiv|iskorištav|dostojanstv|opće dobro|preraspodjel|socijaln[a-zšđčćž]{0,3} nauk|socijaln[a-zšđčćž]{0,3} pravd|laudato si|fratelli tutti|caritas in veritate|evangelii|rerum novarum|enciklik"
clergy_re  <- "biskup|nadbiskup|kardinal|\\bpap(a|e|i|u|om)\\b|papin|sveti otac|svećenik|župnik|velečasn|monsinjor|vatikan|sveta stolic|kaptol|nuncij|\\bkler|crkv[aeou]"
devot_re   <- "\\bmis(a|e|i|u|om)\\b|misn[aeiou]|euharist|sakrament|pričest|krunic|pobožn|hodočašć|korizm|advent|liturgij|\\bgospa\\b|blagoslov|molitv|evanđelj|\\bžup(a|e|i|u|om|ama)\\b|župn|vjernic|vjernik|svijeć|vijenac"
## cost-of-religious-life: price of religious goods/services rising (FIX: separate from 'institution')
crl_re <- paste0("poskupljuju mise|crkven[a-zšđčćž]* (uslug|pristojb|naknad|cjenik|cijen|taks|tarif)|",
  "\\bpristojb[a-zšđčćž]*|naknad[a-zšđčćž]* za (mis|vjenčanj|sprovod|sahran|pogreb)|",
  "cijen[a-zšđčćž]* (mis[aeu]|vjenčanj|sprovod|sahran|pogreb|krsten)|",
  "(mis[aeu]|vjenčanj|sprovod|sahran|pogreb|hodočašć|krsten|krizm|košaric|adventsk|svijeć|vijenac)[a-zšđčćž]* .{0,30}(poskup|skuplj|košta|naknad|euro)|",
  "(poskup|skuplj|digl[ao] cijen|podigl[ao] cijen)[a-zšđčćž]* .{0,30}(mis[aeu]|vjenčanj|sprovod|sahran|pogreb|hodočašć|svijeć|vijenac|košaric)")

cath_re <- "koncil|hkm|laudato|biskup|nadbiskup|župa|zupa|crkva|katol|radio marija|svetiš|samostan|isusov|franjev|salezij|caritas|^vjera|duhovn|novizivot|hrana za dušu|vjeraidjela|svjedočanstv"
biz_re  <- "poslovni|lider|bloomberg|geopolitika|arhivanalitika|energetika|burza|banka|profitiraj|biznis|investor|seebiz|mojnovac|crypto|kripto"

cat("Loading ...\n"); flush.console()
dt <- as.data.table(readRDS("data/merged_comprehensive.rds"))
dt[, rid := .I]
dt[, blob := paste(ifelse(is.na(TITLE),"",TITLE), ifelse(is.na(FULL_TEXT),"",FULL_TEXT))]
dt[, infl_raw := ci(infl_re, blob)]
sub <- dt[infl_raw == TRUE]; N <- nrow(sub); cat("Raw inflation posts:", N, "\n"); flush.console()

Wn <- 220; Wf <- 90
lk_old<-frg_old<-meta<-lk_new<-frg_new<-mC<-mS<-mG<-mD<-mCRL<-logical(N); ctx<-character(N)
crveni <- "crven[aeiou]{0,2}\\s+križ[a-zšđčćž]*"
for (i in seq_len(N)) {
  txt <- sub$blob[i]; nc <- nchar(txt)
  locs <- stri_locate_all_regex(txt, infl_re, opts_regex=opt)[[1]]
  if (is.na(locs[1,1])) next
  ## metaphor: ALL inflation hits metaphorical AND no econ anchor
  meta[i] <- ci(infl_meta, txt) && !ci(econ_anchor, txt)
  ## OLD window (±150) for reproducing strata
  wb_old <- paste(vapply(seq_len(nrow(locs)), function(j) substr(txt, max(1,locs[j,1]-150), min(nc,locs[j,2]+150)), character(1)), collapse=" ¦ ")
  lk_old[i]  <- stri_detect_regex(wb_old, rel_old, opts_regex=opt)
  frg_old[i] <- stri_detect_regex(wb_old, "iran|teheran|trump|biden|putin|moskv|kremlj|ukrajin|venezuel|argentin|zimbabve|washington|bijel[ae] kuć|njemačk|mađarsk|\\bsrbij|beograd|tursk[aeoi]|ankar", opts_regex=opt)
  ## NEW window (±220), Red Cross stripped
  wb <- paste(vapply(seq_len(nrow(locs)), function(j) substr(txt, max(1,locs[j,1]-Wn), min(nc,locs[j,2]+Wn)), character(1)), collapse=" ¦ ")
  wb <- stri_replace_all_regex(wb, crveni, " ", opts_regex=opt)
  lk_new[i] <- stri_detect_regex(wb, rel_new, opts_regex=opt)
  ## foreign: tight adjacency (±90 around any infl hit) OR title has foreign+infl
  tight_for <- any(vapply(seq_len(nrow(locs)), function(j)
    stri_detect_regex(substr(txt, max(1,locs[j,1]-Wf), min(nc,locs[j,2]+Wf)), foreign_gaz, opts_regex=opt), logical(1)))
  ttl <- ifelse(is.na(sub$TITLE[i]),"",sub$TITLE[i])
  frg_new[i] <- tight_for || (ci(foreign_gaz, ttl) && ci(infl_re, ttl))
  ## registers on ±220 window
  mC[i]<-stri_detect_regex(wb,charity_re,opts_regex=opt); mS[i]<-stri_detect_regex(wb,struct_re,opts_regex=opt)
  mG[i]<-stri_detect_regex(wb,clergy_re,opts_regex=opt);  mD[i]<-stri_detect_regex(wb,devot_re,opts_regex=opt)
  mCRL[i]<-stri_detect_regex(wb,crl_re,opts_regex=opt)
  ctx[i] <- gsub("\\s+"," ", substr(paste(vapply(seq_len(min(3L,nrow(locs))), function(j) substr(txt, max(1,locs[j,1]-200), min(nc,locs[j,2]+200)), character(1)), collapse=" ⟫ "),1,850))
}
sub[, `:=`(meta=meta, lk_old=lk_old, frg_old=frg_old, linked=lk_new, foreign=frg_new,
           m_charity=mC, m_struct=mS, m_clergy=mG, m_devot=mD, m_crl=mCRL, ctx=ctx)]
sub[, infl_clean := !meta]
sub[, domestic_linked := infl_clean & linked & !foreign]
## register priority: crl > charity > justice > institution > devotional > other
sub[, register := fifelse(m_crl,"cost_relig_life", fifelse(m_charity,"charity",
      fifelse(m_struct,"justice", fifelse(m_clergy,"institution",
      fifelse(m_devot,"devotional","other")))))]
sub[, otype := fifelse(!is.na(FROM)&ci(cath_re,FROM),"Catholic", fifelse(!is.na(FROM)&ci(biz_re,FROM),"Business","Secular/other"))]

cat("\n=== EFFECT OF FIXES ===\n")
cat(sprintf("metaphor-only inflation dropped: %d\n", sum(sub$meta)))
cat(sprintf("clean inflation posts: %d (was %d raw)\n", sum(sub$infl_clean), N))
cat(sprintf("linked (new, ±220, fixed lexicon): %d (%.1f%% of clean)\n", sum(sub$infl_clean & sub$linked), 100*mean(sub$linked[sub$infl_clean])))
cat(sprintf("foreign-flagged (new): %d\n", sum(sub$infl_clean & sub$foreign)))
cat(sprintf("DOMESTIC genuine linkage: %d (%.1f%% of clean infl)\n", sum(sub$domestic_linked), 100*sum(sub$domestic_linked)/sum(sub$infl_clean)))
cat("\nRegister among domestic-linked:\n"); print(sub[domestic_linked==TRUE, .N, by=register][order(-N)])
cat("\nDomestic-linked by outlet type:\n"); print(sub[domestic_linked==TRUE, .N, by=otype][order(-N)])

## ---------- ANALYSIS-READY CORE ----------
core <- sub[domestic_linked==TRUE, .(rid, DATE, year, month=substr(DATE,1,7), FROM, SOURCE_TYPE, otype,
            register, m_crl, m_charity, m_struct, m_clergy, m_devot, AUTO_SENTIMENT, URL, TITLE, window=ctx)]
saveRDS(core, file.path(OUT, "analysis_core.rds"))
fwrite(core, file.path(OUT, "analysis_core.csv"), bom=TRUE)
cat(sprintf("\nSaved analysis_core: %d posts -> analysis_core.{rds,csv}\n", nrow(core)))

## ---------- REPRODUCE the original 90 sample (old strata) & RESCORE with new classifier ----------
pick <- function(d,n,s){ set.seed(s); if(nrow(d)<=n) d else d[sample(.N,n)] }
subo <- copy(sub); subo[, dom_old := lk_old & !frg_old]
A<-pick(subo[dom_old==TRUE],40,101); B<-pick(subo[lk_old==TRUE & frg_old==TRUE],22,102); C<-pick(subo[lk_old==FALSE],28,103)
s90 <- rbindlist(list(A,B,C)); set.seed(7); s90 <- s90[sample(.N)]; s90[, id := sprintf("%03d", seq_len(.N))]
fwrite(s90[, .(id, new_infl=infl_clean, new_linked=linked, new_foreign=foreign,
               new_domestic=domestic_linked, new_register=register)],
       file.path(OUT, "rescore90_new.csv"), bom=TRUE)
cat("Wrote rescore90_new.csv (new classifier on the original 90 ids)\n")

## ---------- FRESH held-out sample (exclude original 90 rids) ----------
used <- s90$rid
pool <- sub[infl_clean==TRUE & !(rid %in% used)]
pickr <- function(d,n,s){ set.seed(s); if(nrow(d)<=n) d else d[sample(.N,n)] }
HA<-pickr(pool[domestic_linked==TRUE],34,201); HB<-pickr(pool[linked==TRUE & foreign==TRUE],20,202); HC<-pickr(pool[linked==FALSE],26,203)
hs <- rbindlist(list(HA,HB,HC)); set.seed(9); hs <- hs[sample(.N)]; hs[, hid := sprintf("H%02d", seq_len(.N))]
fwrite(hs[, .(hid, new_infl=infl_clean, linked, foreign, domestic_linked, register, otype, DATE, FROM)],
       file.path(OUT, "heldout_auto.csv"), bom=TRUE)
con <- file(file.path(SCR, "heldout_text.txt"), "w", encoding="UTF-8")
for (i in seq_len(nrow(hs))) {
  writeLines(sprintf("### %s | %s | %s", hs$hid[i], hs$DATE[i], hs$FROM[i]), con)
  writeLines(sprintf("TITLE: %s", gsub("\\s+"," ", substr(ifelse(is.na(hs$TITLE[i]),"",hs$TITLE[i]),1,140))), con)
  writeLines(sprintf("CTX: %s", hs$ctx[i]), con); writeLines("", con)
}
close(con)
cat(sprintf("Held-out: %d fresh posts -> heldout_text.txt + heldout_auto.csv (strata %d/%d/%d)\n",
            nrow(hs), nrow(HA), nrow(HB), nrow(HC)))

## ---------- figures (clean) ----------
sub[, mdate := as.Date(paste0(substr(DATE,1,7),"-01"))]
m <- sub[infl_clean==TRUE & !is.na(mdate), .(domestic=sum(domestic_linked),
        foreign=sum(linked & foreign), incidental=sum(!linked)), by=mdate][order(mdate)]
fwrite(m, file.path(OUT,"linkage_monthly_v3.csv"), bom=TRUE)
if (HAS_GG) { library(ggplot2)
  ml <- melt(m, id.vars="mdate", variable.name="v", value.name="n")
  ml[, v := factor(v, levels=c("incidental","foreign","domestic"),
        labels=c("Slučajni suspojav","Inozemna inflacija","Domaća stvarna poveznica"))]
  png(file.path(OUT,"linkage_over_time_v3.png"), width=1150, height=580, res=120)
  print(ggplot(ml, aes(mdate,n,fill=v)) + geom_area(alpha=.9) +
    scale_fill_manual(values=c("Slučajni suspojav"="#D9D9D9","Inozemna inflacija"="#E0B080","Domaća stvarna poveznica"="#8B2E2E")) +
    labs(title="Religija × inflacija (v3, fixevi primijenjeni): domaća poveznica vs. inozemstvo vs. suspojav",
         subtitle="Mjesečni broj objava. Metafore uklonjene, leksikon pročišćen, prozor ±220, strani filtar adjacency.",
         x=NULL,y="Broj objava",fill=NULL) + theme_minimal(base_size=12) + theme(legend.position="top"))
  dev.off()
  mo <- sub[domestic_linked==TRUE & year %in% as.character(2021:2026), .N, by=.(year, register)]
  png(file.path(OUT,"register_by_year_v3.png"), width=1150, height=560, res=120)
  print(ggplot(mo, aes(year,N,fill=register)) + geom_col() +
    labs(title="Registar (v3) — domaće stvarne poveznice po godini", x=NULL,y="Broj objava",fill="Registar") +
    theme_minimal(base_size=12))
  dev.off()
}
cat("\nDONE rerun_fixed\n")

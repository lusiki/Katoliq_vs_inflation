## Build the CODING POOL = all 'linked' candidates (recall ~0.89) + write batch files for the annotators.
suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
opt <- stri_opts_regex(case_insensitive = TRUE)
ci <- function(re, x) stri_detect_regex(x, re, opts_regex = opt) %in% TRUE
OUT <- "studies/inflation-salience/output"
BDIR <- "scratch/batches"  # local working dir for LLM-annotation batch files
dir.create(BDIR, showWarnings=FALSE, recursive=TRUE)

rt <- source("R/religious_terms.R", echo=FALSE)$value
fixreg <- c(gospa="\\bgosp(a|e|i|u|om)\\b|\\bgospin", demon="\\bdemon(a|i|e|u|om|ima)?\\b|demonsk",
            papa="\\bpap(a|e|i|u|om)\\b|papin|sveti otac", misa="\\bmis(a|e|i|u|om|ama)\\b|misn[aeiou]",
            kapitul="\\bkapitul(a|u|om|i|e)?\\b")
for (tm in names(fixreg)) rt$regex[rt$term==tm] <- fixreg[[tm]]
rt <- rt[rt$term != "trapist", ]
rel_re <- paste(rt$regex, collapse="|")
infl_re <- paste0("inflacij|poskup|deflacij|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|kriza troškova|cijene rastu|cijene skaču")
econ_anchor <- paste0("poskup|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|",
  "kriza troškova|cijene rastu|cijene skaču|antiinflacij|inflatorn|inflacijsk[ie] (pritisc|mjer|kretanj)")
infl_meta <- paste0("(hiper|de)?inflacij[a-zšđčćž]*\\s+(?:[a-zšđčćž]+\\s+){0,2}",
  "(riječ|vrijednost|vrednot|pojm|pojam|superlativ|mučenik|osjećaj|titul|diplom|emocij|sadržaj|informacij|fašiz|znanj|straha|nada\\b|nade\\b)")
crveni <- "crven[aeiou]{0,2}\\s+križ[a-zšđčćž]*"
cath_re <- "koncil|hkm|laudato|biskup|nadbiskup|župa|zupa|crkva|katol|radio marija|svetiš|samostan|isusov|franjev|salezij|caritas|^vjera|duhovn|novizivot|hrana za dušu|vjeraidjela|svjedočanstv"
biz_re  <- "poslovni|lider|bloomberg|geopolitika|arhivanalitika|energetika|burza|banka|profitiraj|biznis|investor|seebiz|mojnovac|crypto|kripto"

cat("Loading ...\n"); flush.console()
dt <- as.data.table(readRDS("data/merged_comprehensive.rds"))
dt[, rid := .I]
dt[, blob := paste(ifelse(is.na(TITLE),"",TITLE), ifelse(is.na(FULL_TEXT),"",FULL_TEXT))]
dt[, infl_raw := ci(infl_re, blob)]
sub <- dt[infl_raw==TRUE]; N <- nrow(sub); cat("raw infl:", N, "\n"); flush.console()
W <- 220
meta <- lk <- frg <- logical(N); ctx <- character(N)
for (i in seq_len(N)) {
  txt <- sub$blob[i]; nc <- nchar(txt)
  locs <- stri_locate_all_regex(txt, infl_re, opts_regex=opt)[[1]]; if (is.na(locs[1,1])) next
  meta[i] <- ci(infl_meta, txt) && !ci(econ_anchor, txt)
  wb <- paste(vapply(seq_len(nrow(locs)), function(j) substr(txt, max(1,locs[j,1]-W), min(nc,locs[j,2]+W)), character(1)), collapse=" ¦ ")
  wb <- stri_replace_all_regex(wb, crveni, " ", opts_regex=opt)
  lk[i] <- stri_detect_regex(wb, rel_re, opts_regex=opt)
  ctx[i] <- gsub("\\s+"," ", substr(paste(vapply(seq_len(min(2L,nrow(locs))), function(j) substr(txt, max(1,locs[j,1]-180), min(nc,locs[j,2]+180)), character(1)), collapse=" ⟫ "),1,560))
}
sub[, `:=`(meta=meta, linked=lk, ctx=ctx)]
pool <- sub[meta==FALSE & linked==TRUE]
pool[, otype := fifelse(!is.na(FROM)&ci(cath_re,FROM),"Catholic", fifelse(!is.na(FROM)&ci(biz_re,FROM),"Business","Secular/other"))]
cat("CODING POOL (clean & linked):", nrow(pool), "\n")
saveRDS(pool[, .(rid, DATE, year, FROM, SOURCE_TYPE, otype, AUTO_SENTIMENT, URL, TITLE, ctx)], file.path(OUT,"coding_pool.rds"))
fwrite(pool[, .(rid, DATE, year, FROM, SOURCE_TYPE, otype, URL, TITLE)], file.path(OUT,"coding_pool_index.csv"), bom=TRUE)

## write batch files (75 posts each, one-line CTX so each fits a single Read page)
B <- 75; ids <- seq_len(nrow(pool)); nb <- ceiling(nrow(pool)/B)
for (b in seq_len(nb)) {
  rows <- pool[((b-1)*B+1):min(b*B, nrow(pool))]
  con <- file(sprintf("%s/batch_%03d.txt", BDIR, b), "w", encoding="UTF-8")
  for (i in seq_len(nrow(rows))) {
    writeLines(sprintf("### rid=%d | %s | %s", rows$rid[i], rows$DATE[i], ifelse(is.na(rows$FROM[i]),"",rows$FROM[i])), con)
    writeLines(sprintf("TITLE: %s", gsub("\\s+"," ", substr(ifelse(is.na(rows$TITLE[i]),"",rows$TITLE[i]),1,130))), con)
    writeLines(sprintf("CTX: %s", rows$ctx[i]), con); writeLines("", con)
  }
  close(con)
}
cat("Wrote", nb, "batch files of", B, "to", BDIR, "\n")
cat("NBATCH=", nb, "\n")
cat("DONE pool\n")

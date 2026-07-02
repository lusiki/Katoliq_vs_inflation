## 18_master_jobs.R — reviewer-response jobs that REQUIRE the master corpus.
## Run from the project root on the master machine (same convention as 10_rerun_fixed.R /
## 16_review_response.R: master at data/merged_comprehensive.rds, lexicon at R/religious_terms.R,
## outputs to studies/inflation-salience/output). Needs: data.table, stringi.
##
## Jobs (reviewer items in brackets):
##   J1  rid -> data_source export for the 1,450-candidate pool + 520 core   [enables local stream work]
##   J2  stream-conditioned Table 2: register distribution, monitoring-only  [A2 / must-fix 4a]
##   J3  stream-conditioned Table 4: register x year, monitoring-only        [C1 residual]
##   J4  proximity-window sensitivity ±220/±440/±880/whole-post for linkage
##       and for the structural-justice lexicon                              [A3, B3 / should-fix 9]
##
## Paste the full console output back into the study chat; CSVs land in output/.

suppressWarnings(suppressMessages({ library(data.table); library(stringi) }))
opt <- stri_opts_regex(case_insensitive = TRUE)
ci  <- function(re, x) stri_detect_regex(x, re, opts_regex = opt) %in% TRUE
OUT <- "studies/inflation-salience/output"
TBL <- file.path(OUT, "tables"); dir.create(TBL, showWarnings = FALSE, recursive = TRUE)

## ---------- lexicons: EXACTLY as in 10_rerun_fixed.R (do not edit here without editing there) ----------
rt <- source("R/religious_terms.R", echo = FALSE)$value
fixreg <- c(gospa="\\bgosp(a|e|i|u|om)\\b|\\bgospin", demon="\\bdemon(a|i|e|u|om|ima)?\\b|demonsk",
            papa="\\bpap(a|e|i|u|om)\\b|papin|sveti otac", misa="\\bmis(a|e|i|u|om|ama)\\b|misn[aeiou]",
            kapitul="\\bkapitul(a|u|om|i|e)?\\b")
for (tm in names(fixreg)) rt$regex[rt$term == tm] <- fixreg[[tm]]
rel_new <- paste(rt$regex[rt$term != "trapist"], collapse = "|")

infl_re <- paste0("inflacij|poskup|deflacij|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|kriza troškova|cijene rastu|cijene skaču")
econ_anchor <- paste0("poskup|rast cijen|porast cijen|skok cijen|rast troškov|porast troškov|",
  "troškov[a-zšđčćž]{0,3} života|trošak života|životn[a-zšđčćž]{0,4} trošk|kupovn[a-zšđčćž]{0,3} moć|",
  "kriza troškova|cijene rastu|cijene skaču|antiinflacij|inflatorn|inflacijsk[ie] (pritisc|mjer|kretanj)")
infl_meta <- paste0("(hiper|de)?inflacij[a-zšđčćž]*\\s+(?:[a-zšđčćž]+\\s+){0,2}",
  "(riječ|vrijednost|vrednot|pojm|pojam|superlativ|mučenik|osjećaj|titul|diplom|emocij|sadržaj|informacij|fašiz|znanj|straha|nada\\b|nade\\b)")
struct_re <- "nepravd|nepravedn|siromaš|preferencijaln|ekonomija ubija|nejednakost|strukturn|izrabljiv|iskorištav|dostojanstv|opće dobro|preraspodjel|socijaln[a-zšđčćž]{0,3} nauk|socijaln[a-zšđčćž]{0,3} pravd|laudato si|fratelli tutti|caritas in veritate|evangelii|rerum novarum|enciklik"
crveni <- "crven[aeiou]{0,2}\\s+križ[a-zšđčćž]*"

## ---------- load master + coded artifacts ----------
cat("Loading master ...\n"); flush.console()
dt <- as.data.table(readRDS("data/merged_comprehensive.rds"))
dt[, rid := .I]
pool <- fread(file.path(OUT, "coded_pool_full.csv"), colClasses = list(character = "rid"))
pool[, rid := as.integer(rid)]
core <- as.data.table(readRDS(file.path(OUT, "analysis_core_coded.rds")))
core[, rid := as.integer(rid)]
ds <- dt[, .(rid, data_source)]

## rid integrity: rid is a row index (dt[, rid := .I]). If the master has been re-merged, re-sorted
## or appended since coding, every join below is silently wrong. Assert alignment on DATE + FROM.
chk <- merge(pool[, .(rid, DATE_p = DATE, FROM_p = FROM)], dt[, .(rid, DATE, FROM)], by = "rid")
agree <- mean(chk$DATE_p == chk$DATE & chk$FROM_p == chk$FROM, na.rm = TRUE)
if (nrow(chk) < nrow(pool) || agree < 0.999)
  stop(sprintf("rid alignment FAILED (matched %d/%d, DATE+FROM agreement %.3f): the master snapshot differs from the one used for coding — no join below can be trusted.",
               nrow(chk), nrow(pool), agree))
cat(sprintf("rid integrity OK (%d/%d matched, DATE+FROM agreement %.3f)\n", nrow(chk), nrow(pool), agree))

## ============ J1 — rid -> data_source export ============
cat("\n############ J1 — rid -> data_source map ############\n")
map <- merge(pool[, .(rid)], ds, by = "rid", all.x = TRUE)
map[, in_core := rid %in% core$rid]
fwrite(map, file.path(OUT, "rid_stream_map.csv"), bom = TRUE)
cat(sprintf("Wrote rid_stream_map.csv (%d pool rids; %d in core). Coverage:\n", nrow(map), sum(map$in_core)))
print(map[, .N, by = data_source])

## ============ J2 — stream-conditioned Table 2 (register, monitoring-only) ============
cat("\n############ J2 — Table 2 conditioned on stream [A2] ############\n")
corem <- merge(core, ds, by = "rid", all.x = TRUE)
t2s <- dcast(corem[, .N, by = .(register, data_source)], register ~ data_source, value.var = "N", fill = 0)
if (!"original_dta" %in% names(t2s))
  stop("data_source labels differ from expectation: ", paste(setdiff(names(t2s), "register"), collapse = ", "))
print(t2s[order(-original_dta)])
mon <- corem[data_source == "original_dta"]
if (nrow(mon) == 0) stop("no core rows carry data_source == 'original_dta' — check the stream labels")
cat(sprintf("\nMonitoring-only core n = %d (of %d total)\n", nrow(mon), nrow(corem)))
t2m <- mon[, .(n = .N), by = register][order(-n)][, pct := round(100 * n / sum(n), 1)][]
print(t2m)
macro <- mon[, mean(register %in% c("cost_relig_life", "institution"))]
just  <- mon[, mean(register == "justice")]
cat(sprintf("\n=> STABILITY CHECK (paper claims ~72%% macro / ~2.9%% justice on pooled 520):\n"))
cat(sprintf("   monitoring-only macro-register (crl+institution) = %.1f%%\n", 100 * macro))
cat(sprintf("   monitoring-only justice = %.1f%%\n", 100 * just))
fwrite(t2m, file.path(TBL, "t2_register_monitoring_only.csv"), bom = TRUE)
fwrite(t2s, file.path(TBL, "t2_register_by_stream.csv"), bom = TRUE)

## ============ J3 — stream-conditioned Table 4 (register x year, monitoring-only) ============
cat("\n############ J3 — Table 4 conditioned on stream [C1] ############\n")
t4m <- dcast(mon[, .N, by = .(year, register)], year ~ register, value.var = "N", fill = 0)
print(t4m)
fwrite(t4m, file.path(TBL, "t4_register_by_year_monitoring.csv"), bom = TRUE)

## ============ J4 — proximity-window sensitivity [A3, B3] ============
cat("\n############ J4 — window sensitivity ±220/±440/±880/whole-post ############\n")
dt[, blob := paste(ifelse(is.na(TITLE), "", TITLE), ifelse(is.na(FULL_TEXT), "", FULL_TEXT))]
dt[, infl_raw := ci(infl_re, blob)]
sub <- dt[infl_raw == TRUE]
sub[, meta := ci(infl_meta, blob) & !ci(econ_anchor, blob)]
sub <- sub[meta == FALSE]                     # clean inflation posts, as in the paper (n should be ~8,019)
cat(sprintf("Clean inflation posts: %d\n", nrow(sub)))
if (nrow(sub) != 8019L)
  cat("WARNING: clean-set size differs from the paper's 8,019 — the master snapshot may have changed.\n")
cat("NOTE: linkage below is candidate-stage (pre-foreign-filter) — comparable to the 1,450-candidate\n")
cat("      pool stage, NOT to domestic core counts.\n"); flush.console()

WINDOWS <- c(220L, 440L, 880L, NA_integer_)   # NA = whole post
N <- nrow(sub)
LOCS <- lapply(sub$blob, function(t) stri_locate_all_regex(t, infl_re, opts_regex = opt)[[1]])
res <- data.table(rid = sub$rid)
for (w in WINDOWS) {
  lab <- ifelse(is.na(w), "full", as.character(w))
  lk <- st <- logical(N)
  for (i in seq_len(N)) {
    txt <- sub$blob[i]; nc <- nchar(txt)
    if (is.na(w)) { wb <- txt } else {
      locs <- LOCS[[i]]
      if (is.na(locs[1, 1])) next
      wb <- paste(vapply(seq_len(nrow(locs)), function(j)
        substr(txt, max(1, locs[j, 1] - w), min(nc, locs[j, 2] + w)), character(1)), collapse = " ¦ ")
    }
    wb <- stri_replace_all_regex(wb, crveni, " ", opts_regex = opt)
    lk[i] <- stri_detect_regex(wb, rel_new, opts_regex = opt)
    st[i] <- stri_detect_regex(wb, struct_re, opts_regex = opt)
  }
  res[, paste0("linked_", lab) := lk]
  res[, paste0("struct_", lab) := st]
  cat(sprintf("  window %s: linked candidates = %d, struct-language among linked = %d (%s%%)\n",
              lab, sum(lk), sum(lk & st),
              ifelse(sum(lk) == 0, "NA", sprintf("%.1f", 100 * mean(st[lk]))))); flush.console()
}

cat("\n--- Newly admitted candidates relative to ±220 (the reviewer's selective-loss question) ---\n")
base <- res$linked_220
summ <- rbindlist(lapply(c("440", "880", "full"), function(lab) {
  lw <- res[[paste0("linked_", lab)]]
  sw <- res[[paste0("struct_", lab)]]
  new <- lw & !base
  n_new <- sum(new)
  data.table(window = lab,
             linked_total   = sum(lw),
             newly_admitted = n_new,
             struct_rate_base220_pct   = round(100 * mean(res$struct_220[base]), 1),
             struct_rate_base_at_w_pct = round(100 * mean(sw[base]), 1),
             struct_rate_new_pct       = if (n_new == 0) NA_real_ else round(100 * mean(sw[new]), 1))
}))
print(summ)
cat("=> Compare struct_rate_new_pct against struct_rate_base_at_w_pct (SAME window width, so the\n")
cat("   mechanical more-text-more-matches bias cancels; base220 is context only). If new >> base-at-w,\n")
cat("   the ±220 window drops justice-flavoured posts selectively and the 2.9% floor is biased\n")
cat("   downward [A3]. Otherwise the floor stands.\n")
fwrite(summ, file.path(OUT, "window_sensitivity_summary.csv"), bom = TRUE)

## struct-language recovery among the coded pool (posts already human/LLM-labelled)
cat("\n--- Struct-language recovery within the CODED pool (register from coding) ---\n")
poolw <- merge(pool[, .(rid, c_register, domestic)], res, by = "rid", all.x = FALSE)
cat(sprintf("Coded pool rows matched to window flags: %d of %d\n", nrow(poolw), nrow(pool)))
rec <- poolw[, .(n = .N,
                 struct_220  = sum(struct_220,  na.rm = TRUE),
                 struct_880  = sum(struct_880,  na.rm = TRUE),
                 struct_full = sum(struct_full, na.rm = TRUE)), by = c_register][order(-n)]
print(rec)
cat("=> Rows where struct_880/struct_full >> struct_220 outside the justice register are candidates\n")
cat("   for latent-justice recoding at a wider window [B3 upper bound].\n")

## export the new ±880 candidates for a possible future coding round
newc <- sub[res$linked_880 & !base, .(rid, DATE, FROM, SOURCE_TYPE,
            TITLE = substr(ifelse(is.na(TITLE), "", TITLE), 1, 160))]
newc <- merge(newc, res[, .(rid, struct_880)], by = "rid")
fwrite(newc, file.path(OUT, "window880_new_candidates.csv"), bom = TRUE)
cat(sprintf("\nWrote window880_new_candidates.csv (%d posts admitted at ±880 but not ±220; %d with struct language).\n",
            nrow(newc), sum(newc$struct_880)))
cat("\nDONE 18_master_jobs\n")

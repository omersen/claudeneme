# =============================================================================
# 02_semantic_forms.R
# Gomme dogrulamasi, ISI, dort kisa formun uretimi ve AS4 anlamsal gostergeleri.
# Bu asamada hicbir yanit verisi kullanilmaz.
#   PUB21 : yayimlanmis DASS-21 (sabit anahtar)
#   MIN21 : alt boyutta ISI en dusuk 7 madde
#   MAX21 : alt boyutta ISI en yuksek 7 madde
#   COV21 : 3.432 yedili kume icinde CL_dropped en dusuk kume
#           (esitlik: cfg$cov_tie_rule; "max_SB" -> esitler icinde SB en yuksek, sonra sozluk sirasi)
# =============================================================================
log_event("STAGE", "semantic selection without responses")

prov <- jsonlite::read_json("inputs/embedding_provenance.json", simplifyVector = TRUE)
check("embedding_provenance_model", identical(prov$model, cfg$embedding_model) &&
        prov$dimensions == cfg$embedding_dimensions && prov$n_items == 42L)
check("embedding_derived_sha256",
      identical(digest::digest(file = "inputs/archived_embeddings.csv", algo = "sha256"), prov$derived_sha256))
tab <- read.csv("inputs/archived_embeddings.csv", check.names = FALSE, stringsAsFactors = FALSE)
check("embedding_ids_unique", !anyDuplicated(tab$item_id) && setequal(tab$item_id, p$items$item_id))
tab <- tab[match(p$items$item_id, tab$item_id), , drop = FALSE]
E <- as.matrix(tab[, setdiff(names(tab), "item_id"), drop = FALSE]); rownames(E) <- tab$item_id
check("embedding_dimensions_and_order", nrow(E) == 42L && ncol(E) == cfg$embedding_dimensions &&
        identical(rownames(E), p$items$item_id))
C <- cosine_matrix(E)
check("cosine_symmetry_diagonal_range", max(abs(C - t(C))) < 1e-12 && all(diag(C) == 1) && all(C >= -1 & C <= 1))

forms <- list(FULL42 = lapply(key42, item_id), PUB21 = lapply(key21, item_id),
              MIN21 = list(), MAX21 = list(), COV21 = list())
subset_rows <- metrics_rows <- selection_rows <- optimum_rows <- list()
tol <- cfg$semantic_tolerance

for (f in names(key42)) {
  pool <- forms$FULL42[[f]]; Cf <- C[pool, pool, drop = FALSE]
  isi <- isi_values(Cf)

  # --- MIN21 / MAX21: madde duzeyi ISI siralamasi --------------------------------
  forms$MIN21[[f]] <- sort(rank_with_tolerance(isi)[1:items_per_subscale])
  forms$MAX21[[f]] <- sort(rank_with_tolerance(isi, decreasing = TRUE)[1:items_per_subscale])
  min_max_complement <- length(intersect(forms$MIN21[[f]], forms$MAX21[[f]])) == 0L &&
    setequal(union(forms$MIN21[[f]], forms$MAX21[[f]]), pool)
  log_event("MIN_MAX_complementary", f, min_max_complement)

  # Normalize merkeze benzerlik ile ISI siralamasinin esdegerligi (birim vektorlerde beklenir)
  Un <- E[pool, , drop = FALSE] / sqrt(rowSums(E[pool, , drop = FALSE]^2))
  centroid <- colMeans(Un); centroid <- centroid / sqrt(sum(centroid^2))
  centroid_similarity <- as.numeric(Un %*% centroid); names(centroid_similarity) <- pool
  check(paste0("centroid_ranking_equivalent_", f),
        identical(pool[order(-isi, pool)], pool[order(-centroid_similarity, pool)]))

  # --- Tam sayim: 3.432 yedili kume -----------------------------------------------
  combinations <- utils::combn(sort(pool), items_per_subscale)
  keys <- apply(combinations, 2, paste, collapse = "|")
  ord  <- order(keys); combinations <- combinations[, ord, drop = FALSE]; keys <- keys[ord]
  sm <- t(apply(combinations, 2, function(s) semantic_metrics(Cf, s)))
  check(paste0("all_3432_unique_subsets_", f), nrow(sm) == choose(14, 7) && !anyDuplicated(keys))
  check(paste0("CL_dropped_twice_CL_all_", f), max(abs(sm[, "CL_dropped"] - 2 * sm[, "CL_all"])) < 1e-12)
  check(paste0("SB_identity_", f), max(abs(sm[, "SB"] + sm[, "MIISS"] - 1)) < 1e-12)

  # --- COV21: CL_dropped minimumu ve esitlik kurali ------------------------------------
  best <- min(sm[, "CL_dropped"])
  ties <- which(abs(sm[, "CL_dropped"] - best) <= tol)
  if (cfg$cov_tie_rule == "max_SB" && length(ties) > 1L) {
    sb_best <- max(sm[ties, "SB"])
    ties2 <- ties[abs(sm[ties, "SB"] - sb_best) <= tol]
    chosen <- ties2[order(keys[ties2])][1L]
  } else {
    ties2 <- ties
    chosen <- ties[order(keys[ties])][1L]
  }
  forms$COV21[[f]] <- combinations[, chosen]
  # Esit minimumlarin yapisi: sabit ve degisken maddeler
  tie_sets <- lapply(ties, function(i) combinations[, i])
  common_items  <- Reduce(intersect, tie_sets)
  varying_items <- setdiff(Reduce(union, tie_sets), common_items)
  optimum_rows[[f]] <- data.frame(
    subscale = f, n_subsets = nrow(sm), minimum_CL_dropped = best,
    minimum_tie_count = length(ties), tie_rule = cfg$cov_tie_rule,
    ties_after_secondary_rule = length(ties2),
    selected_subset = keys[chosen], selected_SB = sm[chosen, "SB"],
    tie_common_items = paste(sort(common_items), collapse = ";"),
    tie_varying_items = paste(sort(varying_items), collapse = ";"),
    tie_note = "Esit minimumlar tipik olarak karsilikli en yakin komsu ciftlerinden gelir; sayi 2^k bicimindedir.")
  check(paste0("COV_exact_optimum_", f), abs(semantic_metrics(Cf, forms$COV21[[f]])["CL_dropped"] - best) <= tol)

  subset_rows[[f]] <- data.frame(subscale = f, subset_index = seq_len(nrow(sm)), subset_key = keys, sm,
                                 cov_tied_minimum = seq_len(nrow(sm)) %in% ties, stringsAsFactors = FALSE)
  selection_rows[[f]] <- data.frame(item_id = pool, subscale = f, ISI = as.numeric(isi),
                                    normalized_centroid_similarity = centroid_similarity,
                                    selected_PUB21 = pool %in% forms$PUB21[[f]], selected_MIN21 = pool %in% forms$MIN21[[f]],
                                    selected_MAX21 = pool %in% forms$MAX21[[f]], selected_COV21 = pool %in% forms$COV21[[f]])
  for (nm in form_names) {
    v <- semantic_metrics(Cf, forms[[nm]][[f]]); in_null <- nm != "FULL42"
    metrics_rows[[paste(f, nm)]] <- data.frame(
      subscale = f, form = nm, n_items = length(forms[[nm]][[f]]),
      MIISS = v["MIISS"], SB = v["SB"], CL_dropped = v["CL_dropped"], CL_all = v["CL_all"], CL_max = v["CL_max"],
      SB_percentile = if (in_null) midrank_percentile(sm[, "SB"], v["SB"]) else NA_real_,
      CL_percentile = if (in_null) midrank_percentile(sm[, "CL_dropped"], v["CL_dropped"]) else NA_real_,
      CL_max_percentile = if (in_null) midrank_percentile(sm[, "CL_max"], v["CL_max"]) else NA_real_,
      SB_preferred = "higher", CL_preferred = "lower",
      comparison_set = if (in_null) "all_3432_seven_item_subsets" else "not_length_matched")
  }
}
check("all_short_forms_seven_items_each_subscale", all(vapply(forms[-1], function(z) all(lengths(z) == 7L), logical(1))))

# Onceki paketle sureklilik: MIN21 = eski ISI21 (yalnizca ayni gomme ve kural)
old_path <- "inputs/previous_reference/selected_items.csv"
if (file.exists(old_path)) {
  old_selection <- read.csv(old_path, stringsAsFactors = FALSE)
  for (f in names(key42)) {
    same <- setequal(forms$MIN21[[f]], old_selection$item_id[old_selection$form == "ISI21" & old_selection$subscale == f])
    log_event("MIN21_equals_previous_ISI21", f, same)
  }
}

selected <- do.call(rbind, lapply(form_names, function(nm) do.call(rbind, lapply(names(key42), function(f)
  data.frame(form = nm, subscale = f, item_id = forms[[nm]][[f]])))))
overlap <- list()
for (f in names(key42)) for (pair in utils::combn(short_forms, 2, simplify = FALSE)) {
  x <- forms[[pair[1]]][[f]]; y <- forms[[pair[2]]][[f]]
  overlap[[paste(f, pair[1], pair[2])]] <- data.frame(subscale = f, form_a = pair[1], form_b = pair[2],
    common_items = length(intersect(x, y)), Jaccard = jaccard(x, y))
}
overlap_total <- do.call(rbind, lapply(utils::combn(short_forms, 2, simplify = FALSE), function(pair) {
  x <- unlist(forms[[pair[1]]]); y <- unlist(forms[[pair[2]]])
  data.frame(subscale = "ALL21", form_a = pair[1], form_b = pair[2],
             common_items = length(intersect(x, y)), Jaccard = jaccard(x, y))
}))

sel <- list(forms = forms, C = C, ISI = do.call(rbind, selection_rows),
            semantic_metrics = do.call(rbind, metrics_rows), subsets = do.call(rbind, subset_rows))
csv_out(selected, "selected_items.csv")
csv_out(merge(sel$ISI, p$items[, c("item_id", "text", "word_count")], by = "item_id"), "AS1_ISI_and_selection.csv")
csv_out(data.frame(item_id = rownames(C), C, check.names = FALSE), "cosine_matrix.csv")
csv_out(sel$semantic_metrics, "AS4_semantic_metrics.csv")
csv_out(sel$subsets, "AS4_exact_subset_distribution.csv")
csv_out(do.call(rbind, optimum_rows), "AS4_COV_optimum_audit.csv")
csv_out(rbind(do.call(rbind, overlap), overlap_total), "AS4_form_overlap.csv")
saveRDS(sel, file.path(out, "selection_frozen.rds"))
jsonlite::write_json(prov, file.path(out, "embedding_provenance_used.json"), pretty = TRUE, auto_unbox = TRUE)
log_event("SELECTION_FROZEN", digest::digest(forms, algo = "sha256"))

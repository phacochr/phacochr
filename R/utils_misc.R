slice_sample_seeded <- function(df, seed_cols, n = 1){
  df |>
    group_split() |>
    purrr::map(\(df) {

      seed <- df |>
        slice_head(n = 1) |>
        summarise(seed = sum({{seed_cols}})) |>
        pull(seed)

      set.seed(seed)
      slice_sample(df, n = n)

    }) |> bind_rows()
}



address_fuzzy_matching_by_group <- function(a, b, cols_to_match, group_by, method = "lcs", max_dist = 4, distance_col = "dist_fuzzy", nthread = getOption("sd_num_thread")) {
  a_group_vars <- names(group_by)
  b_group_vars <- unname(group_by)

  # Get unique combinations of group_by columns from a
  var_to_filter <- a |>
    select(all_of(a_group_vars)) |>
    distinct()

  results <- foreach(
    i = seq_len(nrow(var_to_filter)),
    .combine = 'bind_rows',
    .packages = c("dplyr","fuzzyjoin")) %do% {
    current_filter_a <- var_to_filter[i, ]

    # Dynamically build filter expressions for a and b
    filter_expr_a <- map2(a_group_vars, current_filter_a, ~ expr((!!sym(.x)) == !!.y))
    filter_expr_b <- map2(b_group_vars, current_filter_a, ~ expr((!!sym(.x)) == !!.y))

    # Apply filters
    subset_a <- a |> filter(!!!filter_expr_a)
    subset_b <- b |> filter(!!!filter_expr_b)

    # Placeholder logic — can add fuzzy matching here

    stringdist_left_join(subset_a,
                         subset_b,
                         by = cols_to_match,
                         method = method,
                         max_dist = max_dist,
                         distance_col = "dist_fuzzy",
                         nthread = nthread)
    # list(a = subset_a, b = subset_b)
  }

  return(results)
}

# address_fuzzy_matching_by_group(iris, iris, cols_to_match = c("Species" = "Species"), group_by = c("Sepal.Width" = "Sepal.Width", "Sepal.Length" = "Sepal.Length"))
#
#
#



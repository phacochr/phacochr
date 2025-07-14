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

test_that("phaco_geocode renvoie un objet cohérent", {
  data("snacks", package = "phacochr") # adapte si nécessaire

  result <- phaco_geocode(
    data_to_geocode = snacks,
    num = "num",
    rue = "rue",
    code_postal = "code_postal"
  )

  expect_equal(
    nrow(result$data_geocoded),
    nrow(snacks),
    info = "Le nombre de lignes en sortie est différent du nombre de ligne en entrée."
  )

  expect_equal(
    names(result),
    c("summary", "data_geocoded", "data_geocoded_sf"),
    info = "L'objet en sortie comprend ne comprend pas les 3 éléments: summary, data_geocoded et data_geocoded_sf."
  )

  expect_true(
    all(c("x_31370", "y_31370") %in% colnames(result$data_geocoded)),
    info = "Les colonnes 'x_31370' et/ou 'y_31370' sont absentes."
  )

  expect_true(
    all(c("cd_sector", "cd_munty_refnis") %in% colnames(result$data_geocoded)),
    info = "Les colonnes 'cd_sector' et/ou 'cd_munty_refnis' sont absentes."
  )

  expect_true(
    any(!is.na(result$data_geocoded$x_31370)),
    info = "Toutes les valeurs de x_31370 sont NA."
  )
})

# lancer les tests avec devtools::test()

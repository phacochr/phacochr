test_that("phaco_geocode() works", {
  withr::local_seed(42)

  x <- data.frame(
    nom = c(
      paste0("Observatoire de la Sant", "\u00e9", " et du Social"),
      "ULB"
    ),
    rue = c("rue Belliard", "avenue Antoine Depage"),
    num = c("71", "30"),
    code_postal = c("1040", "1000")
  )

  geocoded <- phaco_geocode(
    data_to_geocode = x,
    colonne_rue = "rue",
    colonne_num = "num",
    colonne_code_postal = "code_postal"
  )

  expect_snapshot(geocoded)
})

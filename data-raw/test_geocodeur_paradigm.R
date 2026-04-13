
# Géocodeur Paradigm


library(httr2)


snacks_tom <- read_excel(paste0(path_test, "Exemples/snack_geocode.xlsx"))


# initialiser colonnes
snacks_tom$x_31370 <- NA_real_
snacks_tom$y_31370 <- NA_real_

start<-Sys.time()
for (i in 1:nrow(snacks_tom)) {

  res <- request("https://geoservices.irisnet.be/geocoding/api/v1/brussels/geocoding/freeSearch/searchAnyObject") |>
    req_url_query(
      freeText = snacks_tom$query[i],
      searchLanguage = "fr",
      model = "BeSt"
    ) |>
    req_perform() |>
    resp_body_json()

  # extraction sécurisée
  coords <- tryCatch(
    res$resultsList[[1]]$result[[1]]$address$position$pointGeometry$point$pos[[1]]$value,
    error = function(e) NA
  )

  if (!all(is.na(coords))) {
    snacks_tom$x_31370[i] <- coords[[1]]
    snacks_tom$y_31370[i] <- coords[[2]]
  }

  if (i %% 10 == 0) {
    cat("Ligne", i, "/", nrow(snacks_tom), "\n")
  }

  # optionnel : éviter surcharge API
  # Sys.sleep(0.1)
}
end<-Sys.time()
end-start

snacks_tom





# result<-request("https://geoservices.irisnet.be/geocoding/api/v1/brussels/geocoding/freeSearch/searchAnyObject") |>
#   req_method("GET") |>
#   req_body_json(json_input) |>
#   req_perform()
#
# print(result)
#
#
#
# json_input <- '{
#   "freeText": "63 rue Thieffry 1030",
#   "searchLanguage": "fr",
#   "model": "BeSt"
# }'

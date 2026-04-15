
# Géocodeur Paradigm


library(httr2)
library(readxl)


# path_test <- "C:/0. Unsynchronized Data/PhacochR/" # Joël
snacks_tom <- read_excel(paste0(path_test, "Exemples/snack_geocode.xlsx"))

start<-Sys.time()
for (i in 1:nrow(snacks_tom)) {

  res <- request("https://geoservices.irisnet.be/geocoding/api/v1/brussels/geocoding/freeSearch/searchAnyObject") |>
    req_url_query(
      freeText = snacks_tom$query[i],
      searchLanguage = "fr",
      model = "BeStPlus"
    ) |>
    req_perform() |>
    resp_body_json()

  # extraction sécurisée
  coords <- tryCatch(
    res$resultsList[[1]]$result[[1]]$address$position$pointGeometry$point$pos,
    error = function(e) NA
  )
  houseNumber <- tryCatch(
    res$resultsList[[1]]$result[[1]]$address$houseNumber,
    error = function(e) NA
  )
  streetname <- tryCatch(
    res$resultsList[[1]]$result[[1]]$address$hasStreetName$streetname$name[[1]]$spelling,
    error = function(e) NA
  )
  postalcode <- tryCatch(
    res$resultsList[[1]]$result[[1]]$address$hasPostalInfo$code$objectIdentifier,
    error = function(e) NA
  )

  snacks_tom$paradigm_x_31370[i] <- as.numeric(str_extract_all(coords, "\\w+[.]\\w+")[[1]][1])
  snacks_tom$paradigm_y_31370[i] <- as.numeric(str_extract_all(coords, "\\w+[.]\\w+")[[1]][2])
  snacks_tom$paradigm_houseNumber[i] <- houseNumber
  snacks_tom$paradigm_streetname[i] <- streetname
  snacks_tom$paradigm_postalcode[i] <- postalcode

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

# # COMPARAISON PHACOCHR
# snacks_tom_result <- phaco_geocode(snacks_tom,
#                                    colonne_num_rue_code_postal = "query")
#
# comp <- snacks_tom_result$data_geocoded |>
#   select(query, house_number_sans_lettre, street_detected, code_postal_to_geocode, paradigm_houseNumber, paradigm_streetname, paradigm_postalcode, x_31370, y_31370, paradigm_x_31370, paradigm_y_31370) |>
#   mutate(
#     diff_x = as.numeric(x_31370) - as.numeric(paradigm_x_31370),
#     diff_y = as.numeric(y_31370) - as.numeric(paradigm_y_31370)
#   )

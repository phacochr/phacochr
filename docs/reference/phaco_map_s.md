# phaco_map_s : Carte statique des résultats

Cette fonction produit facilement une carte statique a partir de l'objet
issu du geocodage.

## Usage

``` r
phaco_map_s(
  FULL_GEOCODING_sf,
  colonne_ponderation = NULL,
  title_carto = "adresses geocodees",
  filter_bxl = FALSE,
  aggreg_sector = FALSE,
  zoom_geocoded = FALSE,
  nom_admin = TRUE
)
```

## Arguments

- FULL_GEOCODING_sf:

  L'objet sf à cartographier issu de phaco_geocode().

- colonne_ponderation:

  Un poids pour les points a cartographier.

- title_carto:

  Le titre de la carte produite.

- filter_bxl:

  Afficher uniquement Bruxelles.

- aggreg_sector:

  Procède à l'agrégation des points par secteur statistique pour
  réaliser la cartographie.

- zoom_geocoded:

  Zoomer sur les points.

- nom_admin:

  Afficher les noms des entités administratives sur la carte.

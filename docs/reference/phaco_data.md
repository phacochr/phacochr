# phaco_data : Charger les données qui sont utilisées dans phacochr

Cette fonction permet de charger les données utilisées par phacochr et
qui sont stockée dans l'ordinateur.

## Usage

``` r
phaco_data(data, path_data = NULL)
```

## Arguments

- data:

  Chaîne de caractères indiquant le jeu de données à charger. Les
  valeurs possibles sont :

  - `"rues"` : rues BeST prétraitées pour l'usage de `phacochr`

  - `"adresses"` : adresses BeST prétraitées pour l'usage de `phacochr`

  - `"sec"`, `"sec2024"` : secteurs statistiques Statbel (version
    2019-2024)

  - `"sec2025"` : secteurs statistiques Statbel (version 2025–...)

  - `"sec2011"` : secteurs statistiques Statbel (version 2011-2017)

  - `"conv_sec2024_2025"` : Table de conversion entre les secteurs
    statistiques de 2024 et 2025

  - `"sec_bxl"`, `"sec_bxl2024"` : secteurs statistiques de la Région de
    Bruxelles-Capitale (version 2019-2024)

  - `"sec_bxl2025"` : secteurs statistiques de la Région de
    Bruxelles-Capitale (version 2025–...)

  - `"sec_bxl2011"` : secteurs statistiques de la Région de
    Bruxelles-Capitale (version 2011-2017)

  - `"communes"`, `"communes2024"` : communes de Belgique (version
    2019–2024)

  - `"communes2025"` : communes de Belgique (version 2025-...)

  - `"communes2011"` : communes de Belgique (version 2011-2017)

  - `"communes_bxl"`, `"communes_bxl2024"` : communes de la Région de
    Bruxelles-Capitale (version 2019-2024)

  - `"communes_bxl2025"` : communes de la Région de Bruxelles-Capitale
    (version 2025-...)

  - `"communes_bxl2011"` : communes de la Région de Bruxelles-Capitale
    (version 2011-2017)

  - `"conv_postal_communes2024"` : Table de conversion entre les codes
    postaux et les codes NIS des communes (version 2024)

  - `"quartiers"`, `"quartiers2024"` : quartiers monitoring des
    quartiers (IBSA) sur base des secteurs statistiques (version
    2019-2024)

  - `"quartiers2025"` : quartiers monitoring des quartiers (IBSA) sur
    base des secteurs statistiques (version 2025-...)

  - `"quartiers2011"` : quartiers monitoring des quartiers (IBSA) sur
    base des secteurs statistiques (version 2011-2017)

  - `"couronnes"` : couronnes de Bruxelles (IBSA) sur base des secteurs
    statistiques (version 2019-2024)

  - `"couronnes2024"` : couronnes de Bruxelles (IBSA) sur base des
    secteurs statistiques (version 2019-2024)

  - `"couronnes2025"` : couronnes de Bruxelles (IBSA) sur base des
    secteurs statistiques (version 2025-...)

  - `"qss"` : quartiers social-santé (Vivalis) sur base des secteurs
    statistiques (version 2019-2024)

  - `"bassins"` : bassins (Vivalis) sur base des secteurs statistiques
    (version 2019-2024)

  - `"provinces"` : provinces de Belgique

  - `"regions"` : régions de Belgique

  - `"rbc"` : limites de la Région de Bruxelles-Capitale

  - `"belgique"` : limites de la Belgique

- path_data:

  Chemin absolu vers le dossier où se trouve le données. Par défaut
  data_path = NULL et phacochr trouve le dossier d'installation choisi
  par défaut.

## Examples

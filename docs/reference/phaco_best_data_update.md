# phaco_best_data_update : Mise à jour des données BeST et des fichiers connexes

Cette fonction met à jour les données BeST Address vers la dernière
version disponible sur le site de BOSA : https://opendata.bosa.be ainsi
que les fichiers connexes nécessaires au géocodage.

## Usage

``` r
phaco_best_data_update(
  force = FALSE,
  precision = "cm",
  corrections_REGEX = TRUE,
  path_data = NULL
)
```

## Arguments

- force:

  Force la mise à jour même si les données sont à jour. Par défaut:
  FALSE.

- precision:

  Indique la précision des coordonnées désirées. Par défaut : "cm".
  Choix possibles : "m", "dm", "cm", "mm".

- corrections_REGEX:

  Correction orthographique des adresses BEST. Par défaut: TRUE, car les
  adresses BEST ne sont pas toujours homogènes : elles contiennent des
  précisions entre parenthèses, des abréviations, etc. qui nuisent à la
  détection des rues.

- path_data:

  Chemin absolu vers le dossier où se trouve le données. Par défaut
  data_path = NULL et phacochr trouve le dossier d'installation choisi
  par défaut.

## Examples

``` r
if (FALSE) { # \dontrun{
phaco_best_data_update()
} # }
```

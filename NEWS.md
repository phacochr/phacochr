# phacochr 0.9.1.14

Date : 5 mai 2023

## Modifications majeures

-   Ajout d'une correction des rues BeSTAddress dans la fonction `phaco_best_data_update()`. L'option est activée par défaut, car le formatage des données BeST n'est pas homogène : on trouve parfois dans celles-ci des précisions entre parenthèses (notamment pour Charleroi), des abréviations (St. pour Saint, Av. pour Avenue), etc., ce qui nuit à la bonne détection des rues. L'option est désactivable via le nouvel argument `corrections_REGEX` de la fonction `phaco_best_data_update()`.

# phacochr 0.9.1.13

## Modifications mineures

-   Intégration au package du script `map_process.R` permettant de créer les géométries utilisées dans `phaco_map()` à partir des géométries des secteurs statistiques Statbel et des quartiers du monitoring Urbis (Bruxelles). Le script est situé dans le répertoire `inst/scripts` du package, et peut être appelé via la fonction `system.file()`. Par exemple, en exécutant la commande : `source(paste0(system.file("scripts", package = "phacochr"), "/map_process.R"))`. Le script est intégré par transparence des opérations effectuées, mais il ne semble pas utile d'en faire une fonction, la mise à jour des géométries n'étant pas une opération à réaliser régulièrement.

-   Modification dans la manière de créer les géométries des quartiers du monitoring (Bruxelles). Auparavant, les frontières des quartiers étaient issues du fichier Urbis installé avec le package. Désormais, les géométries des quartiers du monitoring reposent sur les géométries des secteurs statistiques de Stabel, par cohérence avec la manière dont la table *secteurs statistiques - quartiers du monitoring* est créée par la fonction `phaco_best_data_update()`. Ce changement n'a aucun impact sur le fonctionnement et les résultats de `phacochr`, car les géométries des quartiers du monitoring ne sont pas utilisées par les fonctions de `phacochr`. Cette modification modifie simplement le fichier vectoriel des quartiers du monitoring de Bruxelles disponible dans le répertoire d'installation de phacochr (le fichier `C:\Users\USERNAME\AppData\Local\phacochr\phacochr\data_phacochr\STATBEL\PREPROCESSED\BXL_quartiers_PREPROCESSED.gpkg` sous Windows). A terme, il sera utile de créer une fonction rendant facilement disponible ces fichiers pour l'utilisateur.

# phacochr 0.9.1.12

Début de la mise à jour régulière du fichier `NEWS.md` pour documenter les modifications de `phacochr`.

## Modifications mineures

-   Ajout de `ifelse()` pour l'exécution des corrections orthographiques dans la fonction `phaco_geocode()`. Le temps de calcul pour le géocodage diminue de +/- 1%.

# phacochr 1.0

Date : avril 2026

`phacochr` fait peau neuve et présente de grosses modifications dans sa nouvelle version ! De ce fait, la nouvelle version demande de relancer `phaco_setup_data()` pour installer les nouveaux fichiers nécessaires.

## Modifications majeures

-   La rapidité du géocodage a été très largement augmentée : la nouvelle version de `phacochr` est 2 à 5 fois plus rapide que la précédente selon le cas de figure, à la fois pour de petites ou grosses bases de données. `phacochr` a également été optimisé pour trouver des adresses individuelles, bien que ce ne soit pas son utilité première (1-2 sec. pour une adresse unique). D'un point de vue technique, les raisons sont l'optimisation du processus de détection des rues (introduction d'un matching exact avant le matching inexact, agrégation des rues similaires avant leur détection, changement de package de matching inexact [nous passons de `fuzzyjoin` à `fuzzystring`]) et le changement du système de fichiers (nous utilisons des fichiers `.rds` au lieu des `.csv`).

-   Les données géocodées contiennent désormais le nouveau secteur statistique 2025 (les délimitations des secteurs ont changé en 2025). Le secteur 2024 reste présent dans le résultat du géocodage, puisque nous avons anticipé que la migration vers les nouveaux secteurs statistiques ne se fera pas immédiatement pour les différentes institutions.

-   Les anciens noms de rues de Charleroi ont été intégrés suite au renommage récent de nombreuses rues dans la commune. II est désormais possible de trouver la même adresse avec l'ancien ou le nouveau nom.

-   La dimension aléatoire du géocodage a été supprimée. Auparavant, celle-ci pouvait avoir lieu à deux moments. En premier lieu dans la détection des rues : lorsque `phacochr` hésitait entre plusieurs rues après plusieurs tests de ressemblance, l'une d'elle était choisie au hasard. Désormais, c'est la première dans l'ordre alphabétique. En deuxième lieu lorsque le numéro de rue n'était pas trouvé (du fait d'une erreur d'encodage, par exemple) : une approximation était alors réalisée au numéro localisé le plus proche, aléatoirement au dessus ou en dessous du numéro entré par l'utilisateur. Désormais, chaque rue dans BeST défini un sens dans l'approximation, fixé quelle que soit la base de données. *Attention cependant que le sens est différent selon la langue de la rue pour les zones bilingues (comportement à changer ?)*. **Ainsi, à paramètres donnés (mêmes arguments pour le géocodage, même base de données BeST), le résultat sera toujours le même**.

-   Création d'une fonction `phaco_data()`, qui permet d'avoir accès à la plupart des données contenues dans `phacochr`. Ce sont notamment des géométries (secteurs statistiques, quartiers du Monitoring ou quartiers social-santé pour Bruxelles, communes, etc.) et les données de rue ou d'adresses BeST utilisées par `phacochr`. `phaco_data()` contient par ailleurs plusieurs années pour certaines délimitations (communes, secteurs statistiques...).

## Modifications mineures

-   L'output de `phaco_geocode()` est plus propre : les noms ont été simplifiés.

-   Les noms de colonne "interdits" dans la base de données à géocoder ont été réduits à un seul.

-   Un script de préparation des fichiers de base a été ajouté au package (`prepa_fichiers.R` dans `/data_raw`), par transparence vis-à-vis des utilisateurs. Le script renvoie au maximum vers des sources authentiques (principalement Statbel), pour correspondre aux découpages officiels.

-   Un argument `error_max_adj` a été ajouté à `phaco_geocode()` pour déterminer, si l'utilisateur le désire, l'erreur maximale autorisée en cas d'élargissement de la détection de la rue aux communes adjacentes. Par défaut, elle est définie à `error_max/2`.

-   Le nombre de dépendances vis-à-vis de packages externes a été diminué.

-   Le calcul multicore est désormais optionnel dans `phaco_geocode()` et se règle via l'argument `parallel`. Vu l'optimisation du processus de géocodage, le calcul parallélisé n'est plus nécessaire et est désactivé par défaut. Il peut éventuellement être plus performant dans le cas de géocodage de grosses bases de données.

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

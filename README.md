
# phacochr <img src="man/figures/logo_phacoch-R_1.png" align="right" height = 150/>

<!-- badges: start -->

[![R build
status](https://github.com/GuangchuangYu/badger/workflows/R-CMD-check/badge.svg)](https://github.com/GuangchuangYu/badger/actions)
[![GPLv3
license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/phacochr/phacochr/blob/main/LICENSE)
[![Linux](https://svgshare.com/i/Zhy.svg)](https://svgshare.com/i/Zhy.svg)
[![Windows](https://svgshare.com/i/ZhY.svg)](https://svgshare.com/i/ZhY.svg)
[![macOS](https://svgshare.com/i/ZjP.svg)](https://svgshare.com/i/ZjP.svg)

<!-- badges: end -->

PhacochR est un géocodeur pour la Belgique. A partir d’une liste
d’adresse, il permet de retrouver les coordonnées X-Y nécessaires à
toute analyse spatiale.

Le logiciel fonctionne à partir des données publiques [BeST
Address](https://opendata.bosa.be/) compilées par BOSA à partir des
données régionales Urbis (Région de Bruxelles-Capitale), CRAB (Région
flamande) et ICAR (Région wallonne). Il réalise des corrections
orthographiques préalables (via Regex), il fait une jointure inexacte
avec les noms de rues (fuzzyjoin) et trouve le numéro le plus proche -
de préférence du même côté de la rue - si le numéro n’est pas trouvé.

## Installation

Vous pouvez installer le package phacochr depuis
[GitHub](https://github.com/) :

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("phacochr/phacochr")
# Pour installer les données
phacochr::phaco_setup_data()
```

Il est également possible pour l’utilisateur de mettre à jour lui-même
les données [BeST Address](https://opendata.bosa.be/) vers les dernières
mises en ligne :

``` r
phacochr::phaco_update()
```

## Example

``` r
library(phacochr)

x <- data.frame(nom= c("Observatoire de la Santé et du Social", "ULB"),
                rue= c("rue Belliard","avenue Antoine Depage"),
                num=c("71", "30"),
                code_postal=c("1040","1000"))

x
#>                                     nom                   rue num code_postal
#> 1 Observatoire de la Santé et du Social          rue Belliard  71        1040
#> 2                                   ULB avenue Antoine Depage  30        1000
```

``` r
result <- phaco_geocode(data_to_geocode = x,
                        colonne_rue= "rue",
                        colonne_num_rue= "num",
                        colonne_code_postal="code_postal")
#> --- PhacochR ---
#> -- Formatage des données
#> ℹ Région(s) détectée(s) : Bruxelles
#> ⧗ Correction orthographique des adresses[K✔ Correction orthographique des adresses[K
#> -- Géocodage
#> ⧗ Paramétrage pour utiliser 7 coeurs de l'ordinateur✔ Paramétrage pour utiliser 7 coeurs de l'ordinateur[K
#> ⧗ Détection des rues (matching inexact avec fuzzyjoin)✔ Détection des rues (matching inexact avec fuzzyjoin)[K
#> ⧗ Élargissement pour les rues non trouvées aux communes adjacentes✔ Élargissement pour les rues non trouvées aux communes adjacentes[K
#> ⧗ Chargement du fichier openaddress✔ Chargement du fichier openaddress[K
#> ⧗ Jointure avec les coordonnées X-Y✔ Jointure avec les coordonnées X-Y[K
#> ⧗ Approximation à + ou - 100 numéros pour les adresses non localisées✔ Approximation à + ou - 100 numéros pour les adresses non localisées[K
#> -- Résultats
#> ⧗ Création du fichier final et formatage des tables de vérification✔ Création du fichier final et formatage des tables de vérification[K
#> ✔ Géocodage terminé[K
#> 
#> |Region    |  n| Rue detect.(%) | Approx. num(n) | Elarg. com.(n) | Abrev. noms(n) | Geocode(%) |
#> |:---------|--:|:--------------:|:--------------:|:--------------:|:--------------:|:----------:|
#> |Bruxelles |  2|      100       |       0        |       0        |       0        |    100     |
#> |Total     |  2|      100       |       0        |       0        |       0        |    100     |
#> 
#> ℹ Temps de calcul total : 13.4 s
#>              
#> /!\ Toutes les adresses n'ont sans doute pas été trouvées avec certitude /!\
#> - check 'dist_fuzzy' pour les erreurs de reconnaissance des rues
#> - check 'approx_num' pour les approximations de numéro
#> - check 'type_geocoding' pour l'éargissement aux communes adjacentes
#> - check 'nom_propre_abv' pour les abréviations de noms propres
#>              
#> -- Plus de résultats:
#> → Tableau synthétique : $summary
#> → Données géocodées : $data_geocoded
#> → Données géocodées en format sf : $data_geocoded_sf

result$data_geocoded [,c(1,17:19)]
#>   ID_address x_31370 y_31370 cd_sector
#> 1          1  150373  170090 21004B13-
#> 2          2  151105  166831 21004C61-
```

## Auteurs

<center>
<a href="https://www.ccc-ggc.brussels/fr/observatbru/accueil">
<img src="man/figures/logo_observatoire_sante_social.png" align="center" height = 120/>
</a> <a href="https://cartulb.ulb.be/">
<img src="man/figures/logo_ulb_igeat.png" align="center" height = 120/>
</a>
</center>

## Partenariat

<center>
<a href="https://opendata.bosa.be/">
<img src="man/figures/bosa.png" align="center" height = 140/> </a>
</center>

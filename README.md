
# phacochr <img src="man/figures/logo_phacoch-R_1.png" align="right" height = 150/>

<!-- badges: start -->

[![R build
status](https://github.com/GuangchuangYu/badger/workflows/R-CMD-check/badge.svg)](https://github.com/GuangchuangYu/badger/actions)
[![GPLv3
license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
[![Linux](https://svgshare.com/i/Zhy.svg)](https://svgshare.com/i/Zhy.svg)
[![Windows](https://svgshare.com/i/ZhY.svg)](https://svgshare.com/i/ZhY.svg)
[![macOS](https://svgshare.com/i/ZjP.svg)](https://svgshare.com/i/ZjP.svg)

<!-- badges: end -->

PhaochR est un géocodeur pour la Belgique. A partir, d’une liste
d’adresse, il permet de retrouver les coordonnées X-Y nécessaire à toute
analyse spatiale.

Le logiciel fonctionne à partir des données publiques [BeST
Address](https://opendata.bosa.be/) compilées par BOSA à partir des
données régionales Urbis (Région de Bruxelles-Capitale), CRAB (Région
flamande) et ICAR (Région wallonne). Il réalise des corrections
orthographiques préalables (Regex), il fait une jointure inexacte avec
les noms de rues (fuzzyjoin) et il trouve le numéro le plus proche et de
préférence du même côté de la rue si le numéro n’est pas trouvé.

## Installation

Vous pouvez installer le package phacochr depuis
[GitHub](https://github.com/):

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("phacochr/phacochr")
phacochr::phaco_setup_data()
```

## Example

``` r
library(phacochr)
x<- data.frame(nom= c("Observatoire de la Santé et du Social", "ULB"),
               rue= c("rue Beilliard","avenue Antoine Depage"),
               num=c("71", "30"),
               code_postal=c("1040","1000"))
x
#>                                     nom                   rue num code_postal
#> 1 Observatoire de la Santé et du Social         rue Beilliard  71        1040
#> 2                                   ULB avenue Antoine Depage  30        1000
```

``` r
result <-phaco_geocode(data_to_geocode = x,
              colonne_rue= "rue",
              colonne_num_rue= "num",
              colonne_code_postal="code_postal")
#> # A tibble: 3 × 13
#>   Region Effec…¹ Rue d…² strin…³ Geoco…⁴ Appro…⁵ Elarg…⁶ Abrev…⁷ Rue F…⁸ Rue N…⁹
#>   <chr>    <int>   <dbl>   <dbl>   <dbl>   <dbl>   <int>   <int>   <dbl>   <dbl>
#> 1 Total…       2      NA    NA        NA      NA      NA      NA      NA      NA
#> 2 Bruxe…       2     100     0.5     100       0       0       0     100       0
#> 3 Total…       2     100     0.5     100       0       0       0     100       0
#> # … with 3 more variables: `Rue DE` <dbl>, `Coord non valides` <int>,
#> #   Dupliques <int>, and abbreviated variable names ¹​Effectifs,
#> #   ²​`Rue detectee (% tot)`, ³​`stringdist (moy)`, ⁴​`Geocode (% tot)`,
#> #   ⁵​`Approx (% geocodes)`, ⁶​`Elarg (n)`, ⁷​`Abrev (n)`, ⁸​`Rue FR`, ⁹​`Rue NL`
result$data_geocoded [,c(1,17:19)] 
#>   ID_address x_31370 y_31370 cd_sector
#> 1          1  150373  170090 21004B13-
#> 2          2  151105  166831 21004C61-
```

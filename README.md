
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

`phacochr` est un géocodeur pour la Belgique sous forme de package R. A
partir d’une liste d’adresses, il permet de retrouver les coordonnées
X-Y nécessaires à toute analyse spatiale, à un niveau de précision du
bâtiment.

Le programme fonctionne avec les données publiques [BeST
Address](https://opendata.bosa.be/) compilées par BOSA à partir des
données régionales Urbis (Région de Bruxelles-Capitale), CRAB (Région
flamande) et ICAR (Région wallonne). La logique de `phacochr` est de
réaliser une jointure inexacte entre la liste à géocoder et les données
BeST Address grâce aux fonctions des packages R
[fuzzyjoin](https://cran.r-project.org/web/packages/fuzzyjoin/index.html)
et
[stringdist](https://cran.r-project.org/web/packages/stringdist/index.html).
`phacochr` dispose de plusieurs options : il peut notamment réaliser des
corrections orthographiques (en français et néérlandais) préalables à la
détection des rues ou procéder au géocodage au numéro le plus proche -
de préférence du même côté de la rue - si les coordonnées du numéro
indiqué sont inconnues (par exemple si l’adresse n’existe plus). En cas
de non disponibilité du numéro de la rue, le programme indique les
coordonnées du numéro médian de la rue. `phacochr` est compatible avec
les 3 langues nationales : il géocode des adresses écrites en français,
néérlandais ou allemand.

Le package est très rapide pour géocoder de longues listes (+/- 1min40
pour géocoder 20.000 adresses dans les 3 langues et situées dans toute
la Belgique) et le taux de succès pour le géocodage est élevé (médiane
de 97%). `phacochr` constitue donc une alternative très performante face
aux solutions existantes tout en reposant entièrement sur des données
publiques et des procédures libres.

## Installation

Vous pouvez installer le package `phacochr` depuis
[GitHub](https://github.com/). Il est indispensable lors de la première
utilisation d’installer les données nécessaires à son utilisation via la
fonction `phaco_setup_data()`. Ces fichiers (+/- 265Mo) sont téléchargés
et stockés de manière permanente dans un répertoire de travail sur
l’ordinateur (dépendant du système d’exploitation et renseigné par la
fonction lors de l’installation).

``` r
# Installer devtools si celui-ci n'est pas présent sur votre ordinateur
install.packages("devtools")
library(devtools)

# Installer et charger phacochr
devtools::install_github("phacochr/phacochr")
library(phacochr)

# Installer les données nécessaires à phacochr
phaco_setup_data()
```

Il est également possible pour l’utilisateur de mettre à jour lui-même
les données [BeST Address](https://opendata.bosa.be/) (actualisées de
manière hebdomadaire par BOSA) vers les dernières données disponibles en
ligne avec la fonction `phaco_best_data_update()` :

``` r
phaco_best_data_update()
```

## Exemple de géocodage

Voici un exemple de géocodage d’un data.frame contenant deux adresses :

``` r
x <- data.frame(nom = c("Observatoire de la Santé et du Social", "ULB"),
                rue = c("rue Belliard", "avenue Antoine Depage"),
                num = c("71", "30"),
                code_postal = c("1040", "1000"))
x
#>                                     nom                   rue num code_postal
#> 1 Observatoire de la Santé et du Social          rue Belliard  71        1040
#> 2                                   ULB avenue Antoine Depage  30        1000
```

Le géocodage se lance simplement avec la fonction `phaco_geocode()`
appliquée à ce data.frame. Nous indiquons dans cet exemple 3 paramètres
: les colonnes contenant la rue, le numéro de rue et le code postal,
disponibles séparément dans la base de données. Il s’agit de la
situation idéale, mais le programme est compatible avec d’autres
configurations : celles-ci sont renseignée plus bas au point
**Configurations de géocodage possibles**. Mentionnons déjà que le
numéro peut ne pas être renseigné ; `phacochr` trouve alors les
coordonnées du numéro médian de la rue au code postal indiqué. La
fonction dispose de plusieurs options, voir le manuel :
<https://phacochr.github.io/phacochr/>.

``` r
result <- phaco_geocode(data_to_geocode = x,
                        colonne_rue= "rue",
                        colonne_num= "num",
                        colonne_code_postal="code_postal")
```

``` r
result$data_geocoded [,c("ID_address", "x_31370", "y_31370", "cd_sector")]
#>   ID_address x_31370 y_31370 cd_sector
#> 1          1  150373  170090 21004B13-
#> 2          2  151105  166831 21004C61-
```

Le package dispose également d’une fonction de cartographie des adresses
géocodées. `phaco_map_s()` produit des cartes statiques à partir des
données géocodées : il suffit de passer à la fonction l’objet
`data_geocoded_sf` créé précédemment par `phaco_geocode()`. La fonction
dessine alors les coordonnées des adresses sur une carte dont les
frontières administratives sont également affichées. Si les adresses se
restreignent à Bruxelles, la carte se limite automatiquement à la Région
bruxelloise. Les options de la fonction [sont également renseignées dans
le manuel](https://phacochr.github.io/phacochr/).

``` r
phaco_map_s(result$data_geocoded_sf,
            title_carto = "Institutions des auteurs")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Formatage des adresses à géocoder

Cinq configurations de géocodage sont possibles dans `phacochr` :

1.  **Le numéro de rue, la rue et le code postal sont présents dans des
    colonnes séparées dans les données à géocoder :** il s’agit de la
    configuration idéale qui rencontrera le meilleur résultat. Dans ce
    cas, il faut renseigner les arguments `colonne_num`, `colonne_rue`
    et `colonne_code_postal`.
2.  **Le numéro de rue et la rue sont mélangés dans une colonne, et le
    code postal seul dans une autre :** dans ce cas, `phacochr` recrée à
    l’aide des [expressions régulières
    (REGEX)](https://r4ds.had.co.nz/strings.html#matching-patterns-with-regular-expressions)
    la rue et le numéro dans des colonnes séparées. Cette procédure
    fonctionne très bien la plupart du temps. Il faut cependant
    respecter une règle importante : le numéro de rue doit être le
    premier numéro indiqué dans le champ. Un numéro de boite (ou autre
    numéro) ne peut par exemple pas précéder le numéro de rue (cas
    cependant peu courant). Cette configuration demande de renseigner
    les arguments `colonne_num_rue` et `colonne_code_postal`.
3.  **Le numéro de rue, la rue et le code postal sont intégrés dans la
    même colonne :** `phacochr` recrée le numéro de rue, la rue (comme
    la situation précédente) mais aussi le code postal dans des colonnes
    séparées. Cette situation fonctionne également très bien, à
    condition d’observer cette règle : le numéro doit être le premier
    nombre et le code postal être en fin de champ (situations les plus
    courantes). Dans ce cas, il faut renseigner l’argument
    `colonne_num_rue_code_postal`.
4.  **La rue et le code postal sont présents dans des colonnes séparées
    (sans numéro) :** cette situation ressemble à la première, mais sans
    que le numéro soit disponible. `phacochr` géocode alors non pas à un
    niveau de précision du bâtiment, mais choisi comme coordonnée de
    résultat le batiment disposant du numéro médian de la rue au sein du
    même code postal (certaines rues traversant différents codes
    postaux). Cette configuration demande de renseigner les arguments
    `colonne_rue` et `colonne_code_postal`.
5.  **La rue et le code postal sont intégrés dans la même colonne (sans
    numéro) :** le programme recrée la rue et le code postal dans des
    colonnes séparées (comme la situation 3). Dans ce cas, le code
    postal doit être en fin de champ. Lorsque ce n’est pas le cas, le
    programme ne fonctionne pas (situation peu courante). Cette
    configuration demande de renseigner l’argument
    `colonne_rue_code_postal`.

Dans chacune de ces configurations, le programme procède à différentes
corrections pour obtenir les informations nécessaires au géocodage. Le
tableau ci-dessous schématise les différentes configurations, indique
différents exemples à partir d’une même adresse et des notes pour que
l’utilisateur comprenne ce que fait le programme :

![Tableau schématique des configurations
possibles](man/figures/cas_adresses2.png)

## Logique de `phacochr`

Nous expliquons ici avec plus de détail la logique du traitement réalisé
par `phacochr`. Celui-ci repose sur les données BeST Address, que nous
avons largement reformatées pour optimiser le traitement. Nous avons
également utilisé des données produites par Statbel et Urbis dans ce
reformatage. Nous ne rentrons pas dans l’explication de ces
modifications ici, et renvoyons les curieux au [code de la fonction
`phaco_best_data_update()` disponible sur
Github](https://github.com/phacochr/phacochr/blob/main/R/phaco_best_data_update.R).

Nous nous concentrons ici sur les opérations réalisées par la fonction
`phaco_geocode()`, fonction de géocodage à proprement parler. Si l’on
schématise, ces opérations se classent en trois grandes familles :

1)  **Formatage des données :** le programme détecte d’abord la
    configuration des données à géocoder, et créé les colonnes nettoyées
    de numéro de rue (si disponible, ce qui est souvent le cas), de rue
    et de code postal. Des corrections sont faites pour chacun de ces
    champs, afin de maximiser les chances de trouver l’adresse dans la
    suite des opérations.
2)  **Détection des rues :** `phacochr` procède alors à une *jointure
    inexacte* entre chacune des rue (nettoyées au point précédent) et
    l’ensemble des rue de BeST Address *au sein du code postal indiqué*.
    La procédure est réalisée en calcul parallélisé avec n-1 cores afin
    d’augmenter sa vitesse. Le paramètre `error_max` permet d’indiquer
    l’erreur acceptable par l’utilisateur. Celle-ci est réglée par
    défaut à 4, ce qui permet de trouver des rues mal orthographiées,
    sans les confondre avec d’autres, avec un très bon taux de succès.
    Augmenter ce paramètre augmentera le pourcentage de rues trouvées,
    mais aussi d’erreurs réalisées. Dans le cas où la langue dans
    laquelle les adresses sont inscrites est connue, elle peut être
    renseignée via l’argument `lang_encoded`, ce qui augmente la vitesse
    et la fiabilité du processus. Si la rue n’est pas trouvée, le
    programme étend sa recherche à la commune entière et à toutes les
    communes limitrophes. Cette procédure optionnelle peut être
    désactivée avec le paramètre `elargissement_com_adj = FALSE`.
3)  **Jointure avec les coordonnées géographiques :** une fois la rue
    trouvée, il est désormais possible de réaliser une *jointure exacte*
    avec les données BeST au niveau du numéro, celles-ci comprenant les
    coordonnées X-Y de l’ensemble des adresses en Belgique. Pour ce
    faire, seuls les arrondissements dans lesquels sont présents les
    codes postaux sont chargés en RAM, pour augmenter la vitesse et
    soulager l’ordinateur. Les coordonnées des adresses qui ne sont pas
    trouvées sont approximées en trouvant les coordonnées connues de
    l’adresse la plus proche du même côté de la rue. L’amplitude
    maximale de cette approximation est réglabe avec le paramètre
    `approx_num_max` (à régler à 0 pour la désactiver). Dans le cas où
    les coordonnées ne sont pas trouvées, ce sont celles du numéro
    médian de la rue (proxy du milieu de la rue) qui sont indiquées
    (désactivable avec l’argument `mid_street = FALSE`). Si les données
    ne possèdent pas de numéro, c’est cette information qui est indiquée
    comme résultat du géocodage.

La procédure de géocodage est alors finie. Nous terminons les opérations
en joignant à chaque adresse trouvée différentes informations
administratives utiles. Sans être exhaustifs, on y trouve :

-   Les secteurs statistiques (et leurs noms en NL et FR) ;
-   Les codes INS des communes, arrondissements, provinces et regions
    (ainsi que leurs noms en FR et NL) ;
-   Les quartier monitoring pour Bruxelles.

Nous créons également [un objet `sf`](https://r-spatial.github.io/sf/) -
exportable en geopackage ou qui peut être cartographié avec la fonction
`phaco_map_s` - et produisons quelques statistiques indiquant la
performance du géocodage. Le tableau ci-dessous schématise l’ensemble
des opérations réalisées :

<figure>
<img src="man/figures/phacochr4.png" width="500"
alt="Tableau schématique du traitement opéré par phacochr" />
<figcaption aria-hidden="true">Tableau schématique du traitement opéré
par phacochr</figcaption>
</figure>

## Performances de `phacochr`

Nous présentons ici quelques mesures des performances de `phacochr`.
Nous avons réalisés des tests sur 18 bases de données réelles fournies
par des collègues (merci à elles et eux).

La vitesse d’exécution par adresse suit une fonction inverse (1/x).
`phacochr` est beaucoup meilleur avec un nombre conséquent d’adresses.
Ceci vient entre autre du fait qu’il doit charger des données avant de
réaliser les traitements. Pour plus de 2000 adresses, la vitesse
d’exécution se situe entre 0,4 et 0,8 secondes pour 100 adresses. A
titre d’exemple, 2 adresses sont trouvées en 16s, 300 adresses prend
environ 20s, 1000 adresses 25s, 20 000 adresses 140s (1m40).

<figure>
<img src="man/figures/graph_temps_calcul.png" width="500"
alt="Graphique du temps de calcul nécessaire pour géocoder avec phacochr selon le nombre d’adresses à géocoder" />
<figcaption aria-hidden="true">Graphique du temps de calcul nécessaire
pour géocoder avec phacochr selon le nombre d’adresses à
géocoder</figcaption>
</figure>

`phacochr` possède une bonne capacité à trouver les adresses. Sur le
même set de 18 base de données, la médiane du pourcentage d’adresses
trouvées est de 97%. Pour 7 base de données sur les 18 `phacochr`
trouvent à plus de 98%, pour 6 bases de données entre 96% et 98% et pour
5 bases de données entre 90% et 96%.

<img src="man/figures/graph_match_rate.png" width="500"
alt="Graphique du % d’adresses géocodées" /> Ces résultats sur la
performance sont à nuancer par le fait qu’il y a probablement des “faux
positifs”. Pour avoir une idée de la qualités des résultats, il est
conseillé de vérifier quelles corrections orthographiques ont été
réalisée, quelle distance a été acceptée pour réaliser la jointure
inexacte, si un élargissement aux communes adjacentes a été nécessaire
et si un autre numéro que celui renseigné a été choisi (+ ou - x numéro
ou le milieu de la rue).

## Contact

En cas de bug, n’hésitez surtout pas à nous faire part : nous désirons
améliorer le programme et sommes à l’écoute de tout retour. Les deux
auteurs de ce package sont chercheurs en sociologie et en géographie ;
nous ne sommes pas programmeurs de profession, et sommes également
preneurs de toute proposition d’amélioration ! Rendez-vous dans la
section ‘issues’ sur notre
[Github](https://github.com/phacochr/phacochr/issues).

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

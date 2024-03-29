% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/phaco_best_data_update.R
\name{phaco_best_data_update}
\alias{phaco_best_data_update}
\title{phaco_best_data_update : Mise à jour des données BeST et des fichiers connexes}
\usage{
phaco_best_data_update(
  force = FALSE,
  precision = "m",
  corrections_REGEX = TRUE
)
}
\arguments{
\item{force}{Force la mise à jour même si les données sont à jour. Par défaut: FALSE.}

\item{precision}{Indique la précision des coordonnées désirées. Par défaut : "m". Choix possibles : "m", "dm", "cm", "mm".}

\item{corrections_REGEX}{Correction orthographique des adresses BEST. Par défaut: TRUE, car les adresses BEST ne sont pas toujours homogènes : elles contiennent des précisions entre parenthèses, des abréviations, etc. qui nuisent à la détection des rues.}
}
\description{
Cette fonction met à jour les données BeST Address vers la dernière version disponible sur le site de BOSA : https://opendata.bosa.be ainsi que les fichiers connexes nécessaires au géocodage.
}
\examples{
\dontrun{
phaco_best_data_update()
}


}

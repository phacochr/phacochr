.onAttach <- function(libname, pkgname) {
  version <- utils::packageVersion(pkgname)

  packageStartupMessage(
    paste0("phacochr version ", version, " chargé\nJoël t'es trop un bg")
  )
}

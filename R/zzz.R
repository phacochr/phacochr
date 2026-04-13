.onAttach <- function(libname, pkgname) {
  version <- utils::packageVersion(pkgname)

  packageStartupMessage(
    paste0("phacochr version ", version, " charg","\u00e9")
  )
}

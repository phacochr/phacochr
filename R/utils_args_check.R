are_null <- function(...) {
  args <- list(...)
  checks <- sapply(args, is.null)
  return(checks)
}

#' Negation of %in%
#'
#' @description
#' `%ni%` is the negation of `%in%`. It returns `TRUE` for elements of `x`
#' that are not in `y`. `%!in%`, `%ni%` or `%notin%` are equivalent.
#'
#' @param x A vector
#' @param y A vector or list to match against
#'
#' @return A logical vector
#'
#' @examples
#' # Basic usage
#' 1:5 %ni% c(2, 4)
#' 1:5 %!in% c(2, 4)
#' 1:5 %notin% c(2, 4)
#'
#' @export
`%ni%` <- function(x, y) {
  !x %in% y
}

#' @rdname %ni%
#' @export
`%!in%` <- `%ni%`

#' @rdname %ni%
#' @export
`%notin%` <- `%ni%`

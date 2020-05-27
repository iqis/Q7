#' Is it a Q7 Type, Instance or Feature?
#'
#' @param x object
#'
#' @return Boolean
#' @name is
NULL

#' @rdname is
#' @export
is_type <- function(x){
    inherits(x, "Q7type")
}

#' @rdname is
#' @export
is_instance <- function(x){
    inherits(x, "Q7instance")
}

#' @rdname is
#' @export
is_feature <- function(x){
    inherits(x, "Q7feature")
}

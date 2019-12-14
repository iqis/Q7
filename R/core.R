#' Create an Object Generator
#'
#' @param fn a constructor function
#'
#' @return obj::generator, function
#' @export
#'
#' @examples
create <- function(fn){
        fn_body <- deparse(body(fn))
        # insert environment() to the appropriate position depends on whether
        # the body is wrapped with { }
        body(fn) <- parse(text = c("{",
                                   ".my <- structure(environment(),
                                                     class = 'obj::instance')",
                                   `if`(all(fn_body[c(1, length(fn_body))] == c("{", "}")),
                                        fn_body[2:(length(fn_body) - 1)],
                                        fn_body),
                                   ".do <- function(expr) {eval(substitute(expr),
                                                                envir = .my)}",
                                   "return(.my)",
                                   "}"),
                          keep.source = FALSE)
        structure(fn,
                  class = c("obj::generator",
                                class(fn)))
}

#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
is_generator <- function(x){
    inherits(x, "obj::generator")
}

#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
is_instance <- function(x){
    inherits(x, "obj::instance")
}

`print.obj::generator` <- function(x, ...) {
    cat(paste0("<obj::generator>", "\n"))
    print(environment(x))
    print.function(unclass(x))
}


#' Clone
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
clone <- function(...){
    UseMethod("clone")
}


#' Clone an Object Instance
#'
#' @param obj
#' @param deep
#'
#' @return
#' @export
#'
#' @examples
`clone.obj::instance` <- function(obj, deep = TRUE){
    obj_clone <- new.env(parent = parent.env(obj))
    obj_clone$.my <- obj_clone
    names <- setdiff(ls(obj,all.names = TRUE), ".my")
    for (name in names) {
        value <- obj[[name]]
        if (is.function(value)) {
            environment(value) <- obj_clone
        }
        obj_clone[[name]] <- `if`(is_instance(value),
                                 Recall(value,all.names),
                                 value)
    }
    attributes(obj_clone) <- attributes(obj)
    obj_clone
}

#' Create an Object Generator
#'
#' @param fn a constructor function
#'
#' @return s1::generator, function
#' @export
#'
#' @examples
obj <- function(fn){
        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           ".my <- structure(environment(),
                                             class = 's1::instance')",
                           `if`(all(fn_body[c(1, length(fn_body))] ==
                                        c("{", "}")),
                                fn_body[2:(length(fn_body) - 1)],
                                fn_body),
                           ".do <- function(expr){
                                                  eval(substitute(expr),
                                                       envir = .my)

                           }",
                           "return(.my)",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c("s1::generator",
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
    inherits(x, "s1::generator")
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
    inherits(x, "s1::instance")
}

`print.s1::generator` <- function(x, ...) {
    cat(paste0("<s1::generator>", "\n"))
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
`clone.s1::instance` <- function(obj, deep = TRUE){
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

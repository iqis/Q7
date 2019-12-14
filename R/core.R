#' Create an Object Type
#'
#' This function is a object generator
#'
#' @param fn a constructor function
#'
#' @return object::type, function
#' @export
#'
#' @examples
type <- function(fn){
        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           ".my <- structure(environment(),
                                             class = 'object::instance')",
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
                  class = c("object::type",
                            class(fn)))
}

#' Create a Object Feature
#'
#' @param expr
#'
#' @return
#' @export
#'
#' @examples
feature <- function(expr){
    expr <- substitute(expr)
    function(){
        `if`(!exists(".my",
                     envir = parent.frame(),
                     inherits = FALSE),
             stop("Must be called inside an object::instance"))
        eval(expr, envir = parent.frame())
    }
}

#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
is_type <- function(x){
    inherits(x, "object::type")
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
    inherits(x, "object::instance")
}

`print.object::type` <- function(x, ...) {
    cat(paste0("<object::type>", "\n"))
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
`clone.object::instance` <- function(obj, deep = TRUE){
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

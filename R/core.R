#' Create an foo Type
#'
#' This function is a object generator
#'
#' @param fn a constructor function
#'
#' @return foo::type, function
#' @export
#'
#' @examples
type <- function(fn = function(){}, s3_class = "default"){
        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           paste0(".my <- structure(environment(),",
                                             "class = c('", s3_class, "', 'foo::instance'))"),
                           `if`(all(fn_body[c(1, length(fn_body))] ==
                                        c("{", "}")),
                                fn_body[2:(length(fn_body) - 1)],
                                fn_body),
                           ".implement <- function(expr){
                                                  eval(substitute(expr),
                                                       envir = .my)
                                                  invisible(.my)

                           }",
                           "invisible(.my)",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c("foo::type",
                            class(fn)))
}

#' Build an foo::instance from a list
#'
#' @param x
#' @param parent
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
list2inst <- function(x, s3_class = "default", parent = parent.frame(), ...){
    instance <- list2env(x, parent = parent, ...)
    instance$.my <- instance
    migrate_fns <- function(from, to) {
        sapply(Filter(function(.) is.function(get(., envir = from)),
                      ls(envir = from)),
               function(.) {
                   f <- get(., envir = from)
                   environment(f) <- to
                   assign(., f, envir = to)
               })
        invisible(to)
    }
    migrate_fns(instance, instance)
    structure(instance,
              class = s3_class)
}

#' Create an Object Feature
#'
#' @param expr
#'
#' @return
#' @export
#'
#' @examples
feature <- function(expr){
    expr <- substitute(expr)
    fn <- function(obj = parent.frame()){
        `if`(!exists(".my",
                     envir = obj,
                     inherits = FALSE),
             stop("Must be called inside a foo::instance"))
        eval(expr, envir = obj)
        invisible(obj)
    }
    structure(fn, class = "foo::feature")
}


#' Implement any Feature for an Object
#'
#' @param obj
#' @param feat
#'
#' @return
#' @export
#'
#' @examples
implement <- function(obj, feat) {
    feat <- substitute(feat)
    if (is_feature(feat)) {
        feat(obj)
    } else if (is.language(feat)){
        eval(feat, obj)
    }
    invisible(obj)
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
`clone.foo::instance` <- function(obj, deep = TRUE){
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



#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
is_type <- function(x){
    inherits(x, "foo::type")
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
    inherits(x, "foo::instance")
}


#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
is_feature <- function(x){
    inherits(x, "foo::feature")
}


`print.foo::type` <- function(x, ...) {
    cat(paste0("<foo::type>", "\n"))
    print(environment(x))
    print.function(unclass(x))
}



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
type <- function(fn = function(){}, s3 = "default"){
        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           paste0(
                               ".my <- structure(environment(), class = c('", s3, "', 'foo::instance'))"),
                               strip_braces(fn_body),
                           "return(.my)",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c(s3,"foo::type", class(fn)))
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
list2inst <- function(x, s3 = "default", parent = parent.frame(), ...){
    instance <- list2env(x, parent = parent, ...)
    instance$.my <- instance

    (function(from, to) {
        sapply(Filter(function(.) is.function(get(., envir = from)),
                      ls(envir = from)),
               function(.) {
                   f <- get(., envir = from)
                   environment(f) <- to
                   assign(., f, envir = to)
               })
        invisible(to)
    })(instance, instance)

    structure(instance,
              class = s3)
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
    fn <- function(obj = parent.frame()$.my){
        obj_classes <- class(obj)
        if (is_instance(obj)) {
            eval(expr, envir = obj)
        } else if (is_type(obj)) {
            expr <- strip_braces(deparse(expr))
            fn_body <- strip_braces(deparse(body(obj)))
            fn_body <- inject_text(fn_body, expr, length(fn_body) - 1)
            body(obj) <- parse(text = c("{", fn_body, "}"))
        }
        structure(obj, class = obj_classes)
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
    obj_classes <- class(obj)
    if (is_instance(obj)) {
        if (is_feature(feat)) {
            feat(obj)
        } else if (is.language(feat)) {
            eval(feat, obj)
        }
    } else if (is_type(obj)) {
        feat <- strip_braces(deparse(feat))
        fn_body <- strip_braces(deparse(body(obj)))
        fn_body <- inject_text(fn_body, feat, length(fn_body) - 1)
        body(obj) <- parse(text = c("{", fn_body, "}"))
    }
    structure(obj, class = obj_classes)
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



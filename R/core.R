#' Create an Q7 Type
#'
#' This function is a object generator
#'
#' @param fn a constructor function
#'
#' @return Q7::type, function
#' @export
#'
#' @examples
#'
type <- function(fn = function(){}, s3 = "default"){
        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           "(function(){",
                           ".my <- environment()",
                           strip_braces(fn_body),
                           paste0("class(.my) <- c('", s3, "', 'Q7::instance')"),
                           "return(.my)",
                           "})()",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c(s3,"Q7::type", class(fn)))
}



#' Extend upon a Protoype
#'
#' Used only inside a type definition
#'
#' @param prototype Q7::type
#'
#' @return function
#' @export
#'
#' @examples
extend <- function(prototype){
    function(...){
        type_envir <- parent.frame()
        prototype_envir <- localize(prototype, envir = type_envir)(...)
        if (length(ls(prototype_envir)) > 0) {
            migrate_objs(prototype_envir, type_envir)
            migrate_fns(prototype_envir, type_envir)
        }
    }
}

#' Build an Q7::instance from a list
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

#' Create a Generic Feature
#'
#' @param s3
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
feature_generic <- function(s3, ...){
    function(x = parent.frame()$.my, ...){
        UseMethod(s3, x)
    }
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
            fn_body <- inject_text(text_1 = fn_body,
                                   text_2 = expr,
                                   index = length(fn_body) - 2)
            body(obj) <- parse(text = c("{", fn_body, "}"))
        }
        invisible(structure(obj, class = obj_classes))
    }
    structure(fn, class = "Q7::feature")
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
        fn_body <- inject_text(fn_body, feat, length(fn_body) - 3)
        body(obj) <- parse(text = c("{", fn_body, "}"))
    }
    invisible(structure(obj, class = obj_classes))
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
`clone.Q7::instance` <- function(obj, deep = TRUE){
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
    inherits(x, "Q7::type")
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
    inherits(x, "Q7::instance")
}


#' Localize a Type's Environment
#'
#' @param type Q7::type
#' @param envir environment
#'
#' @return Q7::type
#' @export
#'
#' @examples
localize <- function(type, envir = parent.frame()){
    stopifnot(is.function(type))
    environment(type) <- envir
    type
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
    inherits(x, "Q7::feature")
}


`print.Q7::type` <- function(x, ...) {
    cat(paste0("<Q7::type>", "\n"))
    print(environment(x))
    print.function(unclass(x))
}



#' Create an Q7 Type
#'
#' This function is a object generator
#'
#' @param fn a constructor function
#' @param s3 S3 class of the object
#'
#' @return Q7type, function
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
                           paste0("class(.my) <- c('", s3, "', 'Q7instance')"),
                           "return(.my)",
                           "})()",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c("Q7type", class(fn)),
                  s3 = s3)
}

#' Extend a Type upon a Prototype
#'
#' Used only inside a type definition
#'
#' @param prototype Q7type
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
            migrate_elements(prototype_envir, type_envir)
            migrate_fns(prototype_envir, type_envir)
        }
    }
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
    structure(fn, class = "Q7feature")
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

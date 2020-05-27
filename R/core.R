#' Create a Q7 Type
#'
#' @param x function or expression; becomes the definition of the object
#' @param s3 S3 class of the object; necessary when using
#'
#' @return Q7 type; function
#' @export
#'
#' @examples
#'
#' Adder <- type(function(num1, num2){
#'     add_nums <- function(){
#'         num1 + num2
#'     }
#'  })
#'
#' myAdder <- Adder(1, 2)
#' myAdder$add_nums()
#'
type <- function(x = function(){}, s3 = "default"){
        x_char <- deparse(substitute(x))

        if (grepl("function\\(", x_char[1])) { # if x is a function
            fn <- x # then use x
        } else {
            fn <- function(){} # or make a new one
            body(fn) <- substitute(x)
        }

        fn_body <- deparse(body(fn))
        body(fn) <-
            parse(text = c("{",
                           "(function(){",
                           ".my <- environment()",
                           strip_ends(fn_body),
                           paste0("class(.my) <- c('", s3, "', 'Q7instance')"),
                           "return(.my)",
                           "})()",
                           "}"),
                  keep.source = FALSE)

        structure(fn,
                  class = c(s3, "Q7type", class(fn)),
                  s3 = s3)
}

#' Extend a Type upon a (Proto)type
#'
#' Used only inside a type definition
#'
#' @param prototype Q7type; function
#'
#' @return localized Q7type; function
#' @export
#'
#' @examples
#'
#' Type1 <- type(function(arg1){
#'     val1 <- arg1
#'     get_val1 <- function(){
#'         val1
#'     }
#' }, "Type1")
#'
#' Type2 <- type(function(arg1, arg2){
#'     extend(Type1)(arg1)
#'     val2 <- arg2
#'     get_val2 <- function(){
#'         val2
#'     }
#' }, "Type2")
#'
#' myType2 <- Type2("foo", "bar")
#'
#' myType2$get_val1()
#' myType2$get_val2()
#'
extend <- function(prototype){
    function(...){
        type_envir <- parent.frame()
        prototype_envir <- localize(prototype, envir = type_envir)(...)
        # if (length(ls(prototype_envir)) > 0) {
        migrate_elements(prototype_envir, type_envir)
        migrate_elements(parent.env(prototype_envir), parent.env(type_envir))
        migrate_fns(prototype_envir, type_envir)
        migrate_fns(parent.env(prototype_envir), parent.env(type_envir))
        # }
    }
}

#' Create a Generic Feature
#'
#' Use this function when you need to create more than one methods
#' for Q7 types with different S3 classes.
#' The \code{s3} field and the feature's name should be the same.
#'
#' @param s3 S3 Class of the feature
#' @param ... dot-dot-dot
#'
#' @return a generic Q7 feature
#' @export
#'
#' @seealso \code{\link{feature}}
feature_generic <- function(s3, ...){
    function(x = parent.frame()$.my, ...){
        UseMethod(s3, x)
    }
}

#' Create an Object Feature
#'
#' @param expr expression
#'
#' @return a Q7 feature
#' @export
#'
#' @examples
#'
#' Type1 <- type(function(num){})
#'
#' hasMagic <- feature({
#'     change_number <- function(){
#'         num + 1
#'     }
#' })
#'
#' myType1 <- Type1(1) %>% hasMagic()
#' myType1$change_number()
#'
#'
#' # Use S3 method dispatch for different behaviors
#' hasMagic <- feature_generic(s3 = "hasMagic")
#'
#' hasMagic.Type1 <- feature({
#'     change_number <- function(){
#'         num + 1
#'     }
#' })
#'
#' hasMagic.Type2 <- feature({
#'     change_number <- function(){
#'         num - 1
#'     }
#' })
#'
#' Type1 <- type(function(num){},
#'               s3 = "Type1") %>%
#'     hasMagic()
#'
#' Type2 <- type(function(num){},
#'               s3 = "Type2") %>%
#'     hasMagic()
#'
#' myType1 <- Type1(1)
#' myType1$change_number()
#'
#' myType2 <- Type2(1)
#' myType2$change_number()
#'
feature <- function(expr){
    expr <- substitute(expr)
    feature_fn <- function(obj = parent.frame()$.my){
        obj_classes <- class(obj)
        if (is_instance(obj)) {
            eval(expr, envir = obj)
        } else if (is_type(obj)) {
            expr <- strip_ends(deparse(expr))
            obj_fn_body <- strip_ends(deparse(body(obj)))
            obj_fn_body <- inject_text(text_1 = obj_fn_body,
                                   text_2 = expr,
                                   index = length(obj_fn_body) - 2)
            body(obj) <- parse(text = c("{", obj_fn_body, "}"))
        }
        invisible(structure(obj, class = obj_classes))
    }
    structure(feature_fn, class = "Q7feature")
}


#' Implement any Feature for an Object
#'
#' @param obj Q7 object (type or instance)
#' @param feat Q7 feature or expression
#'
#' @return Q7 object (type or instance)
#' @export
#'
#' @examples
#'
#' Type1 <- type(function(num){})
#'
#' myType1 <- Type1(1) %>% implement({
#'     change_number <- function(){
#'         num + 1
#'     }
#' })
#'
#' myType1$change_number()
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
        feat <- strip_ends(deparse(feat))
        fn_body <- strip_ends(deparse(body(obj)))
        fn_body <- inject_text(fn_body, feat, length(fn_body) - 3)
        body(obj) <- parse(text = c("{", fn_body, "}"))
    }
    invisible(structure(obj, class = obj_classes))
}

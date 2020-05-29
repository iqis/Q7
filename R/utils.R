#' Localize a Function's Environment
#'
#' @param fn  function
#' @param envir environment
#'
#' @return function
#' @export
localize <- function(fn, envir = parent.frame()){
  stopifnot(is.function(fn))
  environment(fn) <- envir
  fn
}

#' Clone
#'
#' @param ... dot-dot-dot
#'
#' @export
#'
clone <- function(...){
  UseMethod("clone")
}

#' Clone an Instance
#'
#' @param inst Q7 object instance
#' @param deep to copy nested object instances recursively; Boolean
#' @param ... dot-dot-dot
#'
#' @return Q7 object instance
#' @export
#'
#' @examples
#'
#' Type1 <- type(function(num){
#'   print_num <- function(){
#'     print(num)
#'   }
#' })
#' myType1 <- Type1(1)
#' myType1$print_num()
#' myType1_clone <- clone(myType1)
#' myType1_clone$print_num()
#'
clone.Q7instance <- function(inst, deep = TRUE, ...){
  inst_private <- parent.env(inst)

  inst_clone_private <- new.env(parent = parent.env(inst_private))

  inst_clone <- new.env(parent = inst_clone_private)

  inst_clone_private$.my <- inst_clone
  inst_clone_private$.private <- inst_clone_private

  do_clone <- function(from, to){
    names <- setdiff(ls(from,
                        all.names = TRUE),
                     c(".my",
                       ".private"))
    for (name in names) {
      value <- from[[name]]
      if (is.function(value) &&
          identical(environment(value),
                    from$.my)) {
        environment(value) <- to
      }
      to[[name]] <- `if`(is_instance(value),
                         `if`(deep,
                              clone.Q7instance(inst = value,
                                               deep = deep),
                              value),
                         value)
    }
  }

  do_clone(inst_private, inst_clone_private)
  do_clone(inst, inst_clone)

  # TODO: check for locked bindings, replicate lockedness
  attributes(inst_clone) <- attributes(inst)
  inst_clone
}

#' Build a Q7 Object Instance from a List
#'
#' @param x list
#' @param s3 S3 class name of the instance
#' @param parent parent environment of the instance
#' @param ... dot-dot-dot
#'
#' @return Q7 object instance
#' @export
#'
#' @examples
#' my_data <- list(a = 1,
#'                 add_to_a = function(value){
#'                   .my$a <- a + value
#'                 })
#'
#' myDataObject <- list2inst(my_data)
#'
#' myDataObject$a
#' myDataObject$add_to_a(20)
#' myDataObject$a
#'
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

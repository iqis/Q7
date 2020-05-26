#' Localize a Function's Environment
#'
#' @param fn  function
#' @param envir environment
#'
#' @return function
#' @export
#'
#' @examples
localize <- function(fn, envir = parent.frame()){
  stopifnot(is.function(fn))
  environment(fn) <- envir
  fn
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


#' Clone an Instance
#'
#' @param inst
#' @param deep
#'
#' @return
#' @export
#'
#' @examples
clone.Q7instance <- function(inst, deep = TRUE){
  inst_clone <- new.env(parent = parent.env(inst))
  inst_clone$.my <- inst_clone
  names <- setdiff(ls(inst,all.names = TRUE), ".my")
  for (name in names) {
    value <- inst[[name]]
    if (is.function(value)) {
      environment(value) <- inst_clone
    }
    inst_clone[[name]] <- `if`(is_instance(value),
                              `if`(deep,
                                  Recall(inst = value,
                                         deep = deep),
                                  value),
                              value)
  }
  attributes(inst_clone) <- attributes(inst)
  inst_clone
}

#' Build an Q7instance from a list
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

#' @rdname type
#' @export
print.Q7type <- function(x, ...) {
  cat(paste0("<Q7type>", "\n"))
  print(environment(x))
  print.function(unclass(x))
}

#' @rdname type
#' @export
print.Q7instance <- function(x, ...){
  cat(paste("<Q7instance>", "\n"))
  s3 <- attr(x, "s3")
  cat(`if`(!is.null(s3) && nchar(s3) > 0,
           paste(s3, "\n")))

  element_name_list <- ls(x, all.names = TRUE)
  element_class_list <- lapply(element_name_list, function(y) class(get(y, envir = x)))
  print_line <- function(name, class){
    cat(paste0("- ", name, ": <", paste(class, collapse = ", "), ">\n"))
  }
  mapply(print_line, name = element_name_list, class = element_class_list)
  invisible(x)
}

#' @rdname type
#' @export
is_type <- function(x){
  inherits(x, "Q7type")
}

#' @rdname type
#' @export
is_instance <- function(x){
  inherits(x, "Q7instance")
}

#' @rdname feature
#' @export
is_feature <- function(x){
  inherits(x, "Q7feature")
}

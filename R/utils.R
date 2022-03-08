#' Make a Localized Copy of a Q7 Type or Instance
#'
#'
#' @param obj Q7 type or instance
#' @param envir environment
#'
#' @return function
#' @export
localize <- function(obj, envir = parent.frame()){
  # NOTE convert method dispatch with S3?
  if (is_type(obj)) {
    environment(obj) <- envir
    return(obj)
  } else if (is_instance(obj)) {
    res <- clone(obj)
    parent.env(res) <- envir
    return(res)
  } else {
    stop("Object must be Q7 type or instance.\n")
  }
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
#'     base::print(num)
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

#' Merge all Members of Two Instances
#'
#' All public and private members of instance 2 will be
#' copied to instance 1, overwriting any of the same names.
#'
#' @param inst1 instance to move members to
#' @param inst2 instance to move members from
#'
#' @return Q7 instance, with environment identity of \code{inst1} and members from both instances.
#' @export
#'
#' @examples
#'
#' Screamer <- type(function(words){
#'   scream <- function(){
#'     paste0(paste(words,
#'                  collapse = " "),
#'            "!!!")
#'   }
#' })
#'
#' Whisperer <- type(function(words){
#'   whisper <- function(){
#'     paste0("shhhhhhh.....",
#'            paste(words,
#'                  collapse = " "),
#'            "...")
#'   }
#' })
#'
#' p1 <- Screamer("I love you")
#' p1$scream()
#'
#' p2 <- Whisperer("My parents came back")
#' p2$whisper()
#'
#' p1 <- p1 %>% merge(p2)
#'
#' # note the the "word" for both methods became that of p2
#' p1$whisper()
#' p1$scream()
#'
merge <- function(inst1, inst2) {
  stopifnot(is_instance(inst1) && is_instance(inst2))
  migrate_elements(inst2, inst1)
  migrate_elements(parent.env(inst2), parent.env(inst1))
  migrate_fns(inst2, inst1)
  migrate_fns(parent.env(inst2), parent.env(inst1))
  inst1
}


#' Expose Private Parts of an Instance
#'
#' Creates a reference to the private environment inside an object instance
#'
#' @param inst instance; <Q7instance>
#'
#' @return instance; <Q7instance>
#' @export
#'
#' @examples
#'
#' TypeOne <- type(function(arg){
#'   private[pvt_val] <- 2
#' })
#'
#' instOne <- TypeOne(1)
#' expose_private(instOne)
#'
#' instOne$.private
#' instOne$.private$pvt_val

expose_private <- function(inst){
  stopifnot(is_instance(inst))

  inst$.private <- parent.env(inst)
  inst
}

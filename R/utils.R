strip_braces <- function(text){
    `if`(all(text[c(1, length(text))] == c("{", "}")),
         `if`(length(text) > 2,
              text[2:(length(text) - 1)],
              ""),
         text)
}

inject_text <- function(text_1, text_2, index){
    c(text_1[1:index],
      text_2,
      text_1[(index + 1):length(text_1)])
}


migrate_objs <- function(from, to){
    mapply(assign,
           x  = ls(from),
           value = mget(ls(from), from),
           envir = list(to))
    invisible(to)
}

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

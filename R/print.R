#' @export
print.Q7type <- function(x, ...) {
    cat(paste0("<Q7type:", attr(x, "s3"), ">", "\n"))
    print(environment(x))
}

#' @export
print.Q7instance <- function(x, ...){
    if (exists("print", x)) {
        get("print", x)()
    }
}


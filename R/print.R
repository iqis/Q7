#' @export
print.Q7type <- function(x, ...) {
    cat(paste0("<Q7type>", "\n"))
    print(environment(x))
    print.function(unclass(x))
}

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


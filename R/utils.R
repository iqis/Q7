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

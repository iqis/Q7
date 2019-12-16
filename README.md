
<!-- README.md is generated from README.Rmd. Please edit that file -->

# foo

<!-- badges: start -->

<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) -->

<!-- badges: end -->

Welcome\! `foo` provides *Freestyle Object Oriented* Programming,
featuring:

  - Native R Flavor
      - Everything is familiar
      - Use `<-` to assign value to bindings
  - No Inheritance
      - No lineage to trace back to
      - No methods you don’t need
      - No mess
  - Compostable
      - *Reference Semantics*
      - instance can contain other instances
      - post-hoc `implement()` to add more custom features
  - Unlocked environment/binding
      - Each object is an environment
      - use `.my` to refer to self (optional)
      - Deep copy by default
      - add, remove, change items in an object freely as you please
      - want immutability? don’t write the code that changes things\!

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/foo")
```

## Example

Walk through the following example and see if you can figure out how
`foo` works.

``` r
Dog <- type(function(name, breed){
    say <- function(greeting = "Woof!"){
        cat(paste0(greeting, 
                   " I am ", name, ", a ", breed, 
                   ".\n"))
    }    
})
```

``` r
walter <- Dog("Walter", "Husky")
ls(walter, all.names = TRUE)
#> [1] ".my"   "breed" "name"  "say"
```

``` r
walter$say()
#> Woof! I am Walter, a Husky.
```

``` r
max <- walter %>% clone()
max$name <- "Max"
max$say("Wussup Dawg!")
#> Wussup Dawg! I am Max, a Husky.
```

``` r
max %>% 
  implement({
    treats_eaten <- 0
    eat_treat <- function(n = 1){
      cat(paste(name, "eats", n, "treat(s).\n"))
      treats_eaten <<- treats_eaten + n
    }
  }) %>% 
  implement({
    is_satisfied <- function(){
      treats_eaten > 5
    }
  })
#> <environment: 0x0000000012df0158>
#> attr(,"class")
#> [1] "default"       "foo::instance"
```

``` r
max$eat_treat()
#> Max eats 1 treat(s).
max$is_satisfied()
#> [1] FALSE
max$eat_treat(2)
#> Max eats 2 treat(s).
max$is_satisfied()
#> [1] FALSE
max$eat_treat(3)
#> Max eats 3 treat(s).
max$is_satisfied()
#> [1] TRUE
```

``` r
max$treats_eaten
#> [1] 6
```

``` r
isAnimal <- feature({
    mortal <- TRUE
    eat <- function() paste(.my$name, "eats.")
    poop <- function() paste(name, "poops")
})

max %>% 
  isAnimal()

max$eat()
#> [1] "Max eats."
max$poop()
#> [1] "Max poops"
```

``` r
Person <- type(function(name, job) {
  description <- function(){
    paste(name, "works as a(n)", job)
  }
  isAnimal()
})
archie <- Person("Archie", "Analyst")
```

``` r
archie$description()
#> [1] "Archie works as a(n) Analyst"
archie$poop()
#> [1] "Archie poops"
```

``` r
hasCollar <- feature({
  Collar <- type(function(material, color){
    description <- function() {
      paste("is made of", material, "and in", color)
    }
  })
  
  take_for_a_walk <- function(){
    cat(name, "wears a collar that", collar$description(), "\n")
    cat("We're gonna go out for a walk!")
  }
})
```

``` r
walter %>%
  hasCollar() %>% 
  implement({
    collar <- Collar("metal", "red")
    rm(Collar)
  })
#> <environment: 0x0000000012a99040>
#> attr(,"class")
#> [1] "default"       "foo::instance"
```

``` r
walter$take_for_a_walk()
#> Walter wears a collar that is made of metal and in red 
#> We're gonna go out for a walk!
```

``` r
Employee <- type(function(weekly_hours){NULL}, s3 = "Employee")
john <- Employee(45)
```

``` r
Manager <- type(function(weekly_hours){NULL}, s3 = "Manager")
mike <- Manager(45)
```

``` r
hasOvertime <- feature_generic("hasOvertime")
  
hasOvertime.Employee <- feature({
  is_overtime <- function() weekly_hours > 40
})
hasOvertime.Manager <- feature({
  is_overtime <- function() FALSE
})
```

``` r
john %>% 
  hasOvertime()
john$is_overtime()
#> [1] TRUE
```

``` r
mike %>% 
  implement(hasOvertime())
#> <environment: 0x0000000018a5cac0>
#> attr(,"class")
#> [1] "Manager"       "foo::instance"
mike$is_overtime()
#> [1] FALSE
```

``` r
Boss <- type(function(weekly_hours){
  hasOvertime.Manager()
}, s3 = "Boss")
jill <- Boss(80)
jill$is_overtime()
#> [1] FALSE
```

``` r
my_data <- list(a = 1, 
                add_to_a = function(value){
                  .my$a <- a + value
                })

my_data_obj <- list2inst(my_data)

my_data_obj$a
#> [1] 1
my_data_obj$add_to_a(20)
my_data_obj$a
#> [1] 21
```

TODO: what if features have same bidings? what to do then? - evaluate
each feature to their own environment, each has the parent of .my, or
inside .my - let the user pick and choose what bindings to *import* -
prefix bidings with class name


<!-- README.md is generated from README.Rmd. Please edit that file -->

# foo

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Welcome\! `foo` provides *Freestyle Object Oriented* Programming
features:

  - Native R Flavor
      - Everything is familiar
      - Use `<-` to assign value to bindings
  - No Inheritance
      - No lineage to trace back to
      - No methods you don’t need
      - No mess
  - Compostable
      - *Reference Semantics*
      - use `.my` to refer to self (optional)
      - Deep copy by default
      - post-hoc `$.do()` too add more things
  - Unlocked environment/binding
      - Each object is an environment
      - add, remove, change items in an object freely as you please
      - want immutability? don’t write the code that changes things\!

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/foo")
```

## Example

``` r
dog <- foo::type(function(name, breed){
    say <- function(greeting = "Woof!"){
        cat(paste0(greeting, 
                   " I am ", name, ", a ", breed, 
                   ".\n"))
    }    
})
```

``` r
walter <- dog("Walter", "Husky")
ls(walter, all.names = TRUE)
#> [1] ".do"   ".my"   "breed" "name"  "say"
```

``` r
walter$say()
#> Woof! I am Walter, a Husky.
```

``` r
max <- foo::clone(walter)
max$name <- "Max"
max$say("Wussup Dawg!")
#> Wussup Dawg! I am Max, a Husky.
```

``` r
max$.do({
    treats_eaten <- 0
    eat_treat <- function(n = 1){
        cat(paste(name, "eats", n, "treat(s).\n"))
        treats_eaten <<- treats_eaten + n
    }
})
```

``` r
max$eat_treat()
#> Max eats 1 treat(s).
max$eat_treat(2)
#> Max eats 2 treat(s).
max$eat_treat(3)
#> Max eats 3 treat(s).
```

``` r
max$treats_eaten
#> [1] 6
```

``` r
is_animal <- foo::feature({
    mortal <- TRUE
    eat <- function() paste(.my$name, "eats.")
    poop <- function() paste(name, "poops")
})

max$.do({
    is_animal()
})

max$eat()
#> [1] "Max eats."
max$poop()
#> [1] "Max poops"
```

``` r
person <- foo::type(function(name, job) {
  description <- function(){
    paste(name, "works as a(n)", job)
  }
  is_animal()
})
archie <- person("Archie", "Analyst")
```

``` r
archie$description()
#> [1] "Archie works as a(n) Analyst"
archie$poop()
#> [1] "Archie poops"
```

``` r
has_collar <- foo::feature({
  collar <- foo::type(function(material, color){
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
walter$.do({
  has_collar()
  collar <- collar("rubber", "red")
  })
walter$take_for_a_walk()
#> Walter wears a collar that is made of rubber and in red 
#> We're gonna go out for a walk!
```

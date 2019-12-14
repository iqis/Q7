
<!-- README.md is generated from README.Rmd. Please edit that file -->

# object

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Welcome\! `object` provides the following:

  - Native R Style
      - Everything is familiar
      - Use `<-` to assign value to bindings as object’s items
  - No Inheritance
      - No mess
      - Easy to understand
      - Not unlike today’s hottest languages: Go & Rust
  - Compostable
      - *Reference Semantics*
      - use `.my` to refer to self (optional)
      - Composition is better than Inheritance
      - Deep copy by default
  - Unlocked environment/binding
      - Each object is an environment
      - add, remove, change items in an object freely as you please
      - want immutability? don’t write the code that changes things\!

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/object")
```

## Example

``` r
dog <- object::type(function(name, breed){
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
#> [1] ".implement" ".my"        "breed"      "name"       "say"
```

``` r
walter$say()
#> Woof! I am Walter, a Husky.
```

``` r
max <- object::clone(walter)
max$name <- "Max"
max$say("Wussup Dawg!")
#> Wussup Dawg! I am Max, a Husky.
```

``` r
max$.implement({
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
animal_traits <- object::feature({
    mortal <- TRUE
    eat <- function() paste(.my$name, "eats.")
    poop <- function() paste(name, "poops")
})

max$.implement({
    animal_traits()
})

max$eat()
#> [1] "Max eats."
max$poop()
#> [1] "Max poops"
```

``` r
archie <- object::type(function(name = "Archie", race = "W") NULL )()
```

``` r
Map(function(obj) obj$.implement(animal_traits()), 
    list(walter, archie))
#> [[1]]
#> function() paste(name, "poops")
#> <environment: 0x0000000013b78c60>
#> 
#> [[2]]
#> function() paste(name, "poops")
#> <environment: 0x0000000012654f48>
```

``` r
walter$eat()
#> [1] "Walter eats."
archie$poop()
#> [1] "Archie poops"
```

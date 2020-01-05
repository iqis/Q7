
<!-- README.md is generated from README.Rmd. Please edit that file -->

# foo

<!-- badges: start -->

<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) -->

<!-- badges: end -->

`foo` provides *Freestyle Object Oriented* Programming, a fluid &
powerful paradigm that has many creative uses, featuring:

  - Smart Objects:
      - self-aware
          - Knows about itself
      - active
          - Stores & invokes functions within
      - extensible
          - Make variants of an object
  - No Magic
      - Mechanism decomposes into basic R constructs
          - A type is a function
          - A feature is a function
          - An instance is an environment
      - Same great R syntax & semantics
          - Straightforwardly perform any action on or within an object
          - Follows native lexical scoping rules, almost no NSE
  - Compositional
      - …not hereditary
      - Freely add, change or delete elements, ad/post hoc
      - Focuses on “has-a”, rather than than “is\_a” relationships
      - Objects can contain other objects (Reference Semantics?)
  - Mutable
      - Instances are unlocked environments
      - Easy run time debugging
      - No one stops you from shooting your feet
      - Want safety? Lock’em yourself

Interface

  - `type()`
      - Defines a *type*. (like *class*)
      - Takes a function
      - Returns the same function, plus some other code
      - When invoked, the function’s closure becomes an *instance*,
        which is an environment
          - Contains every binding inside the closure, including
            arguments
          - Also contains `.my`, which refers to the instance itself
  - `feature()`
      - Defines a *feature*
      - Takes any expression
      - Appends the expression to the object
          - Ad hoc: A *feature* can be implemented on a *type*
          - Post hoc: Can also be implemented on an *instance*
  - `implement()`
      - Takes
          - object, a *type* or *instance*
          - any expression (including *features*, but more importantly,
            any arbitrary expression)
      - Returns what was passed in
      - Appends the expresseion to the object

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/foo")
```

## Example

Walk through the following examples and see if you can figure out how
`foo` works.

## Dogs & Humans

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
  implement({
    hasCollar()
    collar <- Collar("metal", "red")
    rm(Collar)
  })
```

``` r
walter$take_for_a_walk()
#> Walter wears a collar that is made of metal and in red 
#> We're gonna go out for a walk!
```

## Overtime

``` r
Employee <- type(function(weekly_hours){}, "Employee")
john <- Employee(45)
```

``` r
Manager <- type(function(weekly_hours){}, "Manager")
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
mike$is_overtime()
#> [1] FALSE
```

``` r
Boss <- 
  type(function(weekly_hours){}) %>% 
  hasOvertime.Manager()
jill <- Boss(80)
jill$is_overtime()
#> [1] FALSE
```

## List-to-Instance

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

## Grade School Geometry

``` r
require(foo)

Circle <- 
    type(function(radius){}, 
         "Circle")
    
Square <- 
    type(function(side){}, 
         "Square")

hasArea <- feature_generic("hasArea")

hasArea.Square <- 
    feature({
        area <- function(){
            .my$side ^ 2
        }
    })

hasArea.Circle <- 
    feature({
        area <- function(){
            .my$radius^2 * pi
        }
    })

circle_1 <- Circle(1) %>% hasArea()
circle_1$area()
#> [1] 3.141593

square_1 <- Square(1) %>% hasArea()
square_1$area()
#> [1] 1


hasArea.EquilateralTriangle <- feature({
    area <- function(){
        (side^2 * sqrt(3)) / 4
    }
})

EquilateralTriangle <- 
    type(function(side){}, 
         "EquilateralTriangle") %>%
    hasArea()

equilateral_triangle_1 <- EquilateralTriangle(1)
equilateral_triangle_1$area()
#> [1] 0.4330127
```

## Flying Rat

``` r
Rat <- type(function(){}, "Rat")
hasWing <- feature({
  can_fly <- TRUE
})
Pigeon <- Rat %>% hasWing()
pigeon <- Pigeon()
pigeon$can_fly
#> [1] TRUE
```

## Locked

``` r
isLocked <- feature({
    lockEnvironment(.my, bindings = TRUE)
})

Test <- type(function(){
    a <- 1
}) %>% isLocked()

test <- Test()
try({
  test$a <- 666
  test$b <- 666
  
  test %>% implement({
    a <- 666
  })
})
#> Error in test$a <- 666 : cannot change value of locked binding for 'a'
```

## State Machine

``` r
State <- type(function(){
    name <- "DEFAULT"
    cat("Processing Current State...\n")
    print_current_state <- function(){
        cat(paste("Current State:", name, "\n"))
    }
})

LockedState <- State %>%
    implement({
        name <- "Locked"
        print_current_state()
        on_event <- function(event) {
            if (event == "8888") {
                return(UnlockedState())
            } else {
                cat("Wrong Password.\n")
                return(.my)
            }
        }
    })

UnlockedState <- State %>%
    implement({
        name <- "Unlocked"
        print_current_state()
        on_event <- function(event) {
            if (event == "lock") {
                return(LockedState())
            } else {
                cat("Invalid Operation. \n")
                return(.my)
            }
        }
    })

SimpleDevice <- type(function(){
    state <- LockedState()
    on_event <- function(event){
        .my$state <- state$on_event(event)
    }
})

device <- SimpleDevice()
#> Processing Current State...
#> Current State: Locked

device$on_event("0000")
#> Wrong Password.
device$on_event("8888")
#> Processing Current State...
#> Current State: Unlocked
device$on_event("do something")
#> Invalid Operation.
device$on_event("lock")
#> Processing Current State...
#> Current State: Locked
```

TODO: what if features have same bidings? what to do then?

  - evaluate each feature to their own environment, each has the parent
    of .my, or inside .my
  - let the user pick and choose what bindings to *import*
  - prefix bidings with type name

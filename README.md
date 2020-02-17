
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) -->

<!-- badges: end -->

`Q7` provides *Freestyle Object Oriented* Programming, a fluid, powerful
and *postmodern* paradigm that borrows from Go and Rust, featuring:

``` r
library(Q7)
#> Loading required package: magrittr
```

Make a type:

``` r
typeOne <- type(function(arg1, arg2){
  
  
})
```

`type()` takes a function, which is used to construct an instance.

Everything defined within the function’s closure becomes elements of the
object. Arguments supplied to the function are accesible to the closure,
but not become elements of the object themselves.

``` r
type_one <- typeOne(1, 2)
type_one$...
#> NULL
```

The object can be modified post-hoc.

``` r
type_one %>% implement({
  
  
})
```

The features implemented can be packaged with `feature()`.

#### Smart Objects

  - self-aware
      - Knows about itself
  - active
      - Bind functions within
  - extensible
      - Make variants of an object (class and instance)

#### No Magic

  - Mechanism decomposes into basic R constructs
      - A type is a function
      - A feature is a function
      - An instance is an environment
  - Same great R syntax & semantics
      - Straightforwardly perform any action on or within an object
      - Follows native scoping rules, almost no NSE

#### Compositional

  - …not quite hereditary
  - Freely add, change or delete elements, ad/post hoc
  - Focuses on “has\_a”, rather than than “is\_a” relationships
  - Objects can contain other objects (what is this called, Reference
    Semantics?)

#### Unlocked

  - Instances are unlocked environments
  - No one stops you from shooting your feet
  - Want safety? Lock’em yourself

### Interface

  - `type()`
      - Defines a *type*. (like *class*)
      - Takes a function
      - Returns the same function, plus some other code
      - When invoked, the function’s closure becomes an *instance*,
        which is an environment
          - Contains every binding inside the closure, except for the
            arguments
          - The arguments are not accessible outside of the object,
            making them private
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
      - Appends the expresseion to the object

`Q7` users should leave behind the grand narrative of classical OOP
orthodoxy, and exploit the benefits of objects as a unit of code, and an
instrument for namespace resolution.

### versus R6

Q7: implicit definition private elements R6: explicit definition of
private

Q7: can add or change features on-the-fly R6: Must unlock object first;
No apparent equivalent

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/Q7")
```

## Examples

Walk through the following comment-free examples and see if you can
figure out how `Q7` works.

### Dogs & Humans

``` r
require(Q7)

Dog <- type(function(name, breed){
    self_intro <- function() {
        paste("My name is", name, "and I'm a", breed)
    }
    fav_food <- NULL
    fav_food2 <- NULL
    set_fav_foods <- function(food, food2) {
        .my$fav_food <- food
        fav_food2 <<- food2
    }
    collar <-  type(function() {
        color <- "red"
        buckle <- type(function(material = "gold"){
            material <- material
        })()
        brand <- "unknown"
    })()
})

Dog
#> function (name, breed) 
#> {
#>     (function() {
#>         .my <- environment()
#>         self_intro <- function() {
#>             paste("My name is", name, "and I'm a", breed)
#>         }
#>         fav_food <- NULL
#>         fav_food2 <- NULL
#>         set_fav_foods <- function(food, food2) {
#>             .my$fav_food <- food
#>             fav_food2 <<- food2
#>         }
#>         collar <- type(function() {
#>             color <- "red"
#>             buckle <- type(function(material = "gold") {
#>                 material <- material
#>             })()
#>             brand <- "unknown"
#>         })()
#>         class(.my) <- c("default", "Q7::instance")
#>         return(.my)
#>     })()
#> }
#> attr(,"class")
#> [1] "default"  "Q7::type" "function"


my_dog <- Dog("Captain Cook", "Boston Terrier")
my_dog$self_intro()
#> [1] "My name is Captain Cook and I'm a Boston Terrier"
my_dog$fav_food
#> NULL
my_dog$set_fav_foods("Sausage", "Bacon")
my_dog$fav_food
#> [1] "Sausage"
my_dog$fav_food2
#> [1] "Bacon"

new_dog <- clone(my_dog)
new_dog
#> <environment: 0x0000000012bdf260>
#> attr(,"class")
#> [1] "default"      "Q7::instance"
my_dog
#> <environment: 0x00000000129637d0>
#> attr(,"class")
#> [1] "default"      "Q7::instance"

new_dog$name <- "Snowy"
new_dog$breed <- "Westie"
new_dog$self_intro()
#> [1] "My name is Snowy and I'm a Westie"
my_dog$self_intro()
#> [1] "My name is Captain Cook and I'm a Boston Terrier"

my_dog$collar
#> <environment: 0x00000000129681f0>
#> attr(,"class")
#> [1] "default"      "Q7::instance"
new_dog$collar$color <- "black"

my_dog$collar$color
#> [1] "red"
new_dog$collar$color
#> [1] "black"

identical(my_dog$collar$buckle, new_dog$collar$buckle)
#> [1] FALSE

my_dog %>% implement({
    owner <- NULL
    come_to_owner <- function(){
        paste(name, "runs toward", owner, 
              "in a collar that is", collar$color)
    }
})

my_dog$owner <- "Jack"
my_dog$come_to_owner()
#> [1] "Captain Cook runs toward Jack in a collar that is red"

ur_dog <- Dog("Fifi", "Bulldog")
ur_dog$collar$color
#> [1] "red"
```

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
#> [1] ".my" "say"
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
}) %>% isAnimal()
archie <- Person("Archie", "Analyst")
```

``` r
archie
#> <environment: 0x000000001410b6c8>
#> attr(,"class")
#> [1] "default"      "Q7::instance"
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

### Formally Extend a Type

``` r
Type1 <- type(function(arg1){
    val1 <- arg1
    get_val1 <- function(){
        val1
    }
}, "Type1")

Type2 <- type(function(arg1, arg2){
    extend(Type1)(arg1)
    val2 <- arg2
    get_val2 <- function(){
        val2
    }
}, "Type2")
```

``` r
type2 <- Type2("one", "two")
type2$val1
#> [1] "one"
type2$val2
#> [1] "two"
type2$get_val1()
#> [1] "one"
type2$get_val2()
#> [1] "two"
```

### Overtime

``` r
Employee <- type(function(weekly_hours){}, "Employee")
john <- Employee(45)
```

``` r
Manager <- type(function(weekly_hours){
  extend(Employee)(weekly_hours)
  is_manager <- TRUE
}, "Manager")

mike <- Manager(45)
```

``` r
hasOvertime <- feature_generic("hasOvertime")
  
hasOvertime.Employee <- feature({
  is_overtime <- function() weekly_hours > 40
})
hasOvertime.Manager <- feature({
  .my$is_overtime <- function() FALSE
})
```

``` r
john %>% hasOvertime()
john$is_overtime()
#> [1] TRUE
```

``` r
mike %>% hasOvertime()
mike$is_overtime()
#> [1] FALSE
```

``` r
Boss <- 
  type(function(weekly_hours){
    weekly_hours <- weekly_hours
  }) %>% 
  hasOvertime.Manager()
jill <- Boss(80)
jill$is_overtime()
#> [1] FALSE
```

### List-to-Instance

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

### Grade School Geometry

``` r
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

circle <- Circle(1) %>% hasArea()
circle$area()
#> numeric(0)

square <- Square(1) %>% hasArea()
square$area()
#> numeric(0)


hasArea.EquilateralTriangle <- feature({
    area <- function(){
        (side^2 * sqrt(3)) / 4
    }
})

EquilateralTriangle <- 
    type(function(side){}, 
         "EquilateralTriangle") %>%
    hasArea()

equilateral_triangle <- EquilateralTriangle(1)
equilateral_triangle$area()
#> [1] 0.4330127
```

### Flying Rat

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

### Locked

``` r
isLocked <- feature({
    lockEnvironment(.my, bindings = TRUE)
})

Test <- type(function(){
    a <- 1
}) %>% isLocked()

test <- Test()
try(test$a <- 666)
#> Error in test$a <- 666 : cannot change value of locked binding for 'a'
try(test$b <- 666)
#> Error in test$b <- 666 : cannot add bindings to a locked environment
try({
  test %>% 
    implement({
      a <- 666
    })
})
#> Error in eval(feat, obj) : cannot change value of locked binding for 'a'
```

### State Machine

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
```

``` r
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

Private Elements

``` r

Counter <- type(function(count = 0){
    add_one <- function(){
      count <<- count + 1
    }
    
    get_count <- function(){
      count
    }
})
```

``` r
counter <- Counter()
ls(counter)
#> [1] "add_one"   "get_count"
counter$get_count()
#> [1] 0
counter$add_one()
counter$add_one()
counter$get_count()
#> [1] 2
```

``` r
R6Example <- R6::R6Class("R6Example", 
                         public = list(
                             a = 1, 
                             b = 2, 
                             f1 = function(){
                                 self$c <- self$a + self$b
                             }, 
                             c = NULL,
                             f2 = function(){
                                 private$d <- self$a + self$b
                             }, 
                             f3 = function(){
                                 private$d
                             }, 
                             initialize = function(){
                                 cat("initializing...")
                             }
                         ), 
                         private = list(
                             d = NULL
                         )
)

r6 <- R6Example$new()
#> initializing...




require(foo)
#> Loading required package: foo
#> 
#> Attaching package: 'foo'
#> The following objects are masked from 'package:Q7':
#> 
#>     clone, extend, feature, feature_generic, implement, is_feature,
#>     is_instance, is_type, list2inst, localize, type
Q7Example <- type(function(var4){
    cat("initializing...")
    var1 <- 1
    var2 <- 2
    fn1 <- function(){
        var3 <<-  var1 + var2
    }
    var3 <- NULL
    fn2 <- function(){
        var4 <<- var1 + var2
    }
    fn3 <- function(){
        var4
    }
})


Q7 <- Q7Example()
#> initializing...
Q7$fn2()
Q7$fn3()
#> [1] 3
```


<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) -->

<!-- badges: end -->

Q7 enables a postmodern flavor of object-oriented programming (OOP), a
simple and flexible paradigm, leaving behind the grand narrative of
classical OOP. Q7 features:

  - Compose objects with `type()`, `feature()` and `implement()`
  - `initialize()` and `finalize()` to run at an object’s beginning and
    the end of life
  - `public`, `private`, `final` and `active` binding modifiers

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/Q7")
```

``` r
require(Q7)
#> Loading required package: Q7
#> Loading required package: magrittr
```

### Example

Make a Q7 object in 3 easy steps.

1, Define an object type:

``` r
Adder <- type(function(num1, num2){
    add_nums <- function(){
        num1 + num2
    }
 })
```

2, Instantiate the object:

``` r
myAdder <- Adder(1, 2)
```

3, Enjoy\!

``` r
myAdder$add_nums()
#> [1] 3
```

#### Smart Objects

  - Functions domestic to an object know:
      - Where am I? What are my neighbors?
  - Extensible
      - Make variants of an object

#### No Magic

  - Mechanism decomposes into basic R constructs
      - A *type* is a function
      - A *feature* is a function
      - An *instance*, created by *type*, is an environment
  - Same great R syntax & semantics
      - Perform any action on or within an object
      - Normal scoping rules

#### Compositional Manner of Construction

  - Freely add, change or delete members, ad or post hoc
  - Focuses on “has a”, rather than than “is a” relationships
  - Objects can contain other objects

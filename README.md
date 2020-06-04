
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/iqis/q7.svg?branch=master)](https://travis-ci.org/iqis/q7)
<!-- badges: end -->

Q7 is a type system that enables a postmodern flavor of compositional
object-oriented programming (OOP), a simple and flexible paradigm,
leaving behind the grand narrative of classical heriditary OOP.

Q7 features:

  - `type()`, `feature()` and `implement()` to compose objects.
  - `initialize()` and `finalize()` to run at an object’s beginning and
    the end of life
  - `public`, `private`, `final`, `private_final` and `active` binding
    modifiers

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

### Features

##### Smart Objects

  - Functions domestic to an object know:
      - Where am I? What are my neighbors?
  - Extensible
      - Make variants of an object

##### Compositional Construction

  - Freely add, change or delete members, ad or post hoc
  - Focuses on *has a*, rather than than *is a* relationships
  - Objects can contain references to other objects

##### No Magic

  - Mechanism decomposes into basic R constructs
      - A *type* is a function
      - A *feature* is a function
      - An *instance*, created by *type*, is an environment
  - Same great R syntax & semantics
      - Perform any action on or within an object
      - Normal scoping rules

**Origin of the Name**

The package was named tounge-in-cheek `foo` for *Freestyle Object
Orientation*, but the author soon realized the smart-a\*\* name is going
to backfire and cause real confusions. The latest OO system in R’s
ecosystem has been S3, S4, S5(RC) and R6. So the author dialed the
alphabet up and the numberal down: Q7, the next-in-line, with a distinct
philosophy. Trivia: Both R6 and Q7 are model names of motor vehicles.

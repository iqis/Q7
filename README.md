
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/iqis/q7.svg?branch=master)](https://travis-ci.org/iqis/q7)
<!-- badges: end -->

Q7 is a type system that enables a postmodern flavor of compositional
object-oriented programming (OOP).

It is simple, flexible and promotes healthy program design. No more
family tree of classes\!

Q7 features:

  - `type()`, `feature()` and `implement()` to compose objects;
  - For each object, `initialize()` and `finalize()` to run at its
    beginning and end of life;
  - For each object, `public`, `private`, `final`, `private_final` and
    `active` binding modifiers to change the visibility and behavior of
    its members.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/Q7")
```

``` r
require(Q7)
#> Loading required package: Q7
#> Loading required package: magrittr
#> 
#> Attaching package: 'Q7'
#> The following object is masked from 'package:base':
#> 
#>     merge
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

See vignettes for extending an object and other topics.

### Features

##### Smart Objects

  - Contains reference to self: `.my`
  - Object methods know:
      - Which object do I belong to?
      - Which are other members of the same object?

##### Compositional Construction

  - Freely add, change or delete members, ad or post hoc, without
    subclassing
  - Focuses on *has-a*, rather than than *is-a* relationships
  - Objects can contain references to other objects

##### No Magic

  - All mechanisms are built from basic R constructs
      - A *type* is a function
      - A *feature* is a function
      - An *instance*, created by *type* and *feature*, is an
        environment
  - Same great R syntax & semantics
      - Perform any action on or within an object
      - Normal scoping rules you would expect

\_\_\*Origin of the Name\_\_

The package was named `foo` for *Freestyle Object Orientation*, but the
author soon realized the smart-a\*\* name is going to cause confusions.
As it is more streamelined than R6, but represents progress in OO
philosophy, the author dialed the alphabet down and the numberal up.


<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

<!-- [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) -->

<!-- badges: end -->

Q7 enables a postmodern flavor of object-oriented programming (OOP), a
flexible and powerful paradigm. Q7 features:

  - Compositional manner of construction with `type()`, `feature()` and
    `implement()`
  - Define `initialize()` and `finalize()` to run at the beginning and
    the end
  - Has `public`, `private`, `final` and `active` binding modifiers

`Q7` users can leave behind the grand narrative of the OOP orthodoxy,
and enjoy

#### Smart Objects

  - functions within an object know:
      - Where am I? What are my neighbors?
  - extensible
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

## Installation

``` r
# install.packages("devtools")
devtools::install_github("iqis/Q7")
```

### Example

To make an object:

``` r
require(Q7)
#> Loading required package: Q7
#> Loading required package: magrittr
Adder <- type(function(num1, num2){
  
  
})
```

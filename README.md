
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Q7

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/iqis/q7.svg?branch=master)](https://travis-ci.org/iqis/q7)
<!-- badges: end -->

Q7 is a type system that enables a postmodern flavor of compositional
object-oriented programming (OOP). It is simple, flexible and promotes
healthy program design.

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

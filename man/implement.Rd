% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core.R
\name{implement}
\alias{implement}
\title{Implement any Feature for an Object}
\usage{
implement(obj, feat)
}
\arguments{
\item{obj}{Q7 object (type or instance)}

\item{feat}{Q7 feature or expression}
}
\value{
Q7 object (type or instance)
}
\description{
Implement any Feature for an Object
}
\examples{

Type1 <- type(function(num){})

myType1 <- Type1(1) \%>\% implement({
    change_number <- function(){
        num + 1
    }
})

myType1$change_number()
}

require(Q7)

test_that("type() can take either function or expression", {
                TypeOne <- type(function(){var <- 1})
                TypeTwo <- type({var <- 2})
                expect_equal(TypeOne()$var, 1)
                expect_equal(TypeTwo()$var, 2)
})


test_that("type() can take a function passed in as an argument", {
                                        # from iss19
    type_size <- function(size){ }
    size <- Q7::type(type_size, s3 = "ggsd.size")
    x <- size(1)
    
    expect_s3_class(x, "ggsd.size")

    one_fn <- function(){var <- 1}
    TypeOne <- type(one_fn)
    expect_equal(TypeOne()$var, 1)
})

test_that("Type & instances have right S3 classes", {

        TypeOne <- type(s3 = "TypeOne")

        expect_s3_class(TypeOne, "TypeOne")
        expect_s3_class(TypeOne, "Q7type")
        expect_s3_class(TypeOne(), "TypeOne")
        expect_s3_class(TypeOne(), "Q7instance")
})

test_that("Aruments in constructor are not allocated to public environment but private", {

        TypeOne <- type(function(v1, v2){

        })
        myTypeOne <- TypeOne(1,2)
        expect_equal(ls(myTypeOne), character())

        myTypeOne %>%
                implement({
                        .private <- .private
                })

        expect_true(all(c("v1", "v2") %in% ls(myTypeOne$.private)))
})

test_that("Member function can access private members.", {
        TypeOne <- type(function(arg){
                private[var] <- 0
                private_final[var2] <- 0
                fn <- function(){
                        c(arg, var, var2)
                }
        })
        myTypeOne <- TypeOne(0)
        expect_setequal(myTypeOne$fn(),
                        c(0, 0, 0))
})


test_that("Private member function can access public member.", {

        TypeOne <- type(function(){
                var <- 0
                private[fn] <- function(){
                        var
                }
                fn2 <- function(){
                        fn()
                }
        })

        myTypeOne <- TypeOne()

        expect_equal(c(myTypeOne$var,
                       myTypeOne$fn2()),
                     c(0,
                       0))
})

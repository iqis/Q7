require(Q7)
test_that("No keywords found in public environment.", {
        TypeOne <- type()
        expect_equal(ls(TypeOne()),
                     character())
})

test_that("All keywords are found in private environment.", {
        TypeOne <- type() %>% implement({
                .private <- .private
        })

        expect_setequal(ls(TypeOne()$.private),
                        c("[<-.active", "[<-.final", "[<-.private",
                          "[<-.private_active", "[<-.private_final", "[<-.public",
                          "finalize", "initialize", "print",
                          "active", "final", "public",
                          "private", "private_active", "private_final"))
})

test_that("initialize() can access members and is evaluated.", {

        TypeOne <- type(function(arg){
                var <- 0
                initialize <- function(){
                        public[var2] <- 0
                        private[var3] <- 0
                        base::print(arg + var + var2 + var3)
                }
        })

        expect_output(TypeOne(0), "0")
})

test_that("finalize() is evaluated when object is destroyed.", {
        flag <- FALSE
        TypeOne <- type(function(){
                private[finalize] <- function(e){
                        flag <<- TRUE
                }
        })
        myTypeOne <- TypeOne()
        rm(myTypeOne)
        gc()
        expect_true(flag)
})

test_that("Active members work.", {

        TypeOne <- type(function(){
                active[var] <- function(){
                        0
                }

        })

        myTypeOne <- TypeOne()

        expect_equal(myTypeOne$var,
                     0)
})

test_that("Final members throw error when assigned new value. ", {
        TypeOne <- type(function(){
                final[var] <- 0
                private_final[var2] <- 0
                attempt_to_change <- function(){
                        var2 <<- 1
                }
        })
        myTypeOne <- TypeOne()

        expect_error(myTypeOne$var <- 1)
        expect_error(myTypeOne$attempt_to_change())
})

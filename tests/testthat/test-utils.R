library(Q7)

TestType <- type(function(arg1){
        val2 <- 2
})

test_that("expose_private() guards on input", {
        expect_error(expose_private(TestType))
})

test_that("expose_private() creates a reference to private env named .private", {

        testInst <- TestType(1)
        expose_private(testInst)

        expect_true(exists(".private",
                           envir = testInst))

        expect_identical(testInst$.private,
                         parent.env(testInst))

})

test_that("expose_private() exposes private elements in instance.", {

        testInst <- TestType(1)
        expose_private(testInst)

        expect_equal(testInst$.private$arg1,
                     1)
})

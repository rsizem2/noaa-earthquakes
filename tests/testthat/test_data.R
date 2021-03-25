
suppressWarnings(data <- eq_read_data())

# Tests for eq_read_data
test_that("output is not empty",{
    expect_true(nrow(data) > 0)
})

test_that("output has correct column names",{
    expect_true(all(c("YEAR", "MONTH", "DAY",
                      "HOUR", "MINUTE", "SECOND",
                      "TSUNAMI", "VOLCANO","LOCATION") %in% colnames(data)))
})

# Tests for eq_location_clean
test_that("calling with no arguments yields non-empty tibble",{
    suppressWarnings(temp <- eq_location_clean())
    expect_true(nrow(temp) > 0)
})

suppressWarnings(temp <- eq_location_clean(data))

test_that("passing output from eq_read_data yields non-empty tibble",{
    expect_true(nrow(temp) > 0)
})

suppressWarnings(temp <- tibble::tibble(LOCATION = c("JAPAN:TOKYO","MEXICO:")) %>%
                     eq_location_clean())

test_that("correct columns are created and removed",{
    expect_true(exists("temp"))
    expect_true("COUNTRY" %in% colnames(temp))
    expect_true("REGION" %in% colnames(temp))
    expect_false("LOCATION" %in% colnames(temp))
})

test_that("parses test data correctly",{
    expect_true(exists("temp"))
    expect_true(temp$COUNTRY[1] == "JAPAN")
    expect_true(temp$COUNTRY[2] == "MEXICO")
    expect_true(temp$REGION[1] == "TOKYO")
    expect_true(is.na(temp$REGION[2]))
})


# Tests for eq_clean_data

suppressWarnings(temp <- eq_read_data() %>% tail(n = 10))

test_that("eq_clean_data and eq_location_clean are commutative",{
    suppressWarnings(temp1 <- temp %>% eq_location_clean() %>% eq_clean_data())
    suppressWarnings(temp2 <- temp %>% eq_clean_data() %>% eq_location_clean())
    expect_true(all.equal(temp1,temp2))
})

test_that("eq_clean_data produces output when given no arguments",{
    suppressWarnings(temp <- eq_clean_data())
    expect_true(nrow(temp) > 0)
})

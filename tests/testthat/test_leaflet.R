
suppressWarnings(temp <- tibble::tibble(LONGITUDE = c(0.0),
                                LATITUDE = c(0.0),
                                REGION = "LOS ANGELES",
                                DATE = lubridate::ymd_hms(c("2000-01-01 12:00:00")),
                                MAG = c(9),
                                TOTAL_DEATHS = c(10)))

# Tests eq_map

test_that("eq_map doesn't accept invalid dataframes",{
    expect_error(temp %>% dplyr::select(-LONGITUDE) %>% eq_map())
    expect_error(temp %>% dplyr::select(-LATITUDE) %>% eq_map())
    expect_error(temp %>% dplyr::select(-DATE) %>% eq_map())
    expect_error(temp %>% dplyr::select(-MAG) %>% eq_map())
})


# Tests eq_create_label

test_that("eq_create_label doesn't accept invalid dataframes",{
    expect_error(temp %>% dplyr::select(-TOTAL_DEATHS) %>% eq_create_label())
    expect_error(temp %>% dplyr::select(-REGION) %>% eq_create_label())
    expect_error(temp %>% dplyr::select(-MAG) %>% eq_create_label())
})

test_that("label contains expected sub strings",{
    suppressWarnings(temp <- temp %>% eq_create_label())
    expect_true(grepl("<b>Location:</b>LOS ANGELES<br>", temp, fixed = TRUE))
    expect_true(grepl("<b>Magnitude:</b>9<br>", temp, fixed = TRUE))
    expect_true(grepl("><b>Total Deaths:</b>10<br>", temp, fixed = TRUE))
})

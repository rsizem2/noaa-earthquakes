suppressWarnings(data <- eq_clean_data() %>%
                     dplyr::filter(!is.na(TOTAL_DEATHS)) %>%
                     dplyr::select(DATE, YEAR, COUNTRY, REGION, LONGITUDE, LATITUDE, MAG, TOTAL_DEATHS) %>%
                     tidyr::drop_na() %>%
                     dplyr::filter(COUNTRY == "JAPAN", YEAR >= 2000) %>%
                     utils::head())

# Test geom_timeline

test_that("leaving off required aes throws error", {
    expect_true(nrow(data) > 0)
    temp <- data %>% ggplot2::ggplot() + geom_timeline()
    expect_error(print(temp))
                  })

# Test geom_timeline_label

test_that("leaving off required aes throws error", {
    expect_true(nrow(data) > 0)
    temp <- data %>% ggplot2::ggplot(aes(label = TOTAL_DEATHS)) + geom_timeline_label()
    expect_error(print(temp))
    temp <- data %>% ggplot2::ggplot(aes(x = DATE)) + geom_timeline_label()
    expect_error(print(temp))
})

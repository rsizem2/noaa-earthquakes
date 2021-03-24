#' Reads in the raw data from the `inst/extdata` directory. Renames some columns, drops some irrelevant columns and converts all column names to uppercase.
#'
#' @return dataframe
#'
#' @importFrom readr read_tsv
#' @importFrom magrittr %>%
#' @importFrom dplyr rename select slice n
#'
#' @export

eq_read_data <- function(){
    data <- readr::read_tsv(system.file("extdata","earthquakes-2021-03-08_17-02-58_-0500.tsv",
                                package = "earthquakes")) %>%
        dplyr::slice(2:dplyr::n()) %>%
        dplyr::rename(Year = Year,
                      Month = Mo,
                      Day = Dy,
                      Hour = Hr,
                      Minute = Mn,
                      Second = Sec,
                      Tsunami = Tsu,
                      Volcano = Vol,
                      Location = "Location Name")
    colnames(data) <- gsub(" ", "_", toupper(colnames(data)))
    data <- data %>% dplyr::select(-contains("DESCRIPTION"))
}

#' Formats the LOCATION column correctly, removing redundant COUNTRY/REGION information.
#'
#' @return dataframe
#'
#' @importFrom stringr str_locate str_split
#' @importFrom magrittr %>%
#' @importFrom dplyr as_tibble mutate select if_else
#'
#'
#'
#' @export

eq_location_clean <- function(){
    data <- eq_read_data()
    temp <- stringr::str_split(data$LOCATION, ":", n = 2, simplify = TRUE) %>%
        dplyr::as_tibble()
    colnames(temp) <- c("COUNTRY","REGION")
    temp <- temp %>%
        dplyr::mutate(COUNTRY = trimws(COUNTRY),
                      REGION = trimws(REGION)) %>%
        dplyr::mutate(COUNTRY = dplyr::if_else(COUNTRY == "", NA_character_, COUNTRY),
                      REGION = dplyr::if_else(REGION == "", NA_character_, REGION))
    data <- data %>%
        dplyr::mutate(COUNTRY = temp$COUNTRY,
                      REGION = temp$REGION,
                      .before = LOCATION) %>%
        dplyr::select(-LOCATION)
}


#' Cleans and formats the rawdata
#'
#'
#' @param rawdata dataframe returned from `eq_read_data` function
#'
#' @importFrom dplyr rename mutate transmute if_else
#' @importFrom lubridate ymd years
#' @importFrom magrittr %>%
#' @importFrom tidyr replace_na
#' @importFrom stringr str_pad
#'
#'
#' @export

eq_clean_data <- function(rawdata){
    rawdata <- eq_location_clean() %>%
        dplyr::mutate(MONTH = tidyr::replace_na(MONTH,1),
                      DAY = tidyr::replace_na(DAY,1),
                      TSUNAMI = dplyr::if_else(is.na(TSUNAMI), FALSE, TRUE),
                      VOLCANO = dplyr::if_else(is.na(VOLCANO), FALSE, TRUE)) %>%
        dplyr::mutate(OFFSET = dplyr::if_else(YEAR < 0, abs(YEAR), 0),
                      .before = YEAR) %>%
        dplyr::mutate(YEAR = stringr::str_pad(dplyr::if_else(YEAR < 0, 0, YEAR), 4, pad = "0"),
                      MONTH = stringr::str_pad(MONTH, 2, pad = "0"),
                      DAY = stringr::str_pad(DAY, 2, pad = "0"),
                      HOUR = stringr::str_pad(HOUR, 2, pad = "0"),
                      MINUTE = stringr::str_pad(MINUTE, 2, pad = "0"),
                      SECOND = stringr::str_pad(SECOND, 2, pad = "0")) %>%
        dplyr::mutate(DATE = lubridate::ymd(paste(YEAR,MONTH,DAY,sep = "-")) - lubridate::years(OFFSET),
                      .before = OFFSET)
}
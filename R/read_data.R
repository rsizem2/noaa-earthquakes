#' Reads in the raw data from the `inst/extdata` directory.
#'
#' @return dataframe
#'
#' @importFrom readr read_tsv
#' @importFrom magrittr %>%
#' @importFrom dplyr rename slice n
#'
#' @export

eq_read_data <- function(){
    readr::read_tsv(system.file("extdata","earthquakes-2021-03-08_17-02-58_-0500.tsv",
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
}

#' Formats the LOCATION_NAME column correctly.
#'
#' @return dataframe
#'
#' @importFrom stringr str_locate
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate select if_else
#'
#'
#'
#' @export

eq_location_clean <- function(){
    rawdata <- eq_read_data() %>%
        dplyr::mutate(colon = grepl(":", Location),
                      temp = gsub("^[^:]+:", "", Location)) %>%
        dplyr::mutate(Location = dplyr::if_else(colon,
                                                trimws(temp),
                                                trimws(Location))) %>%
        dplyr::select(-c(colon, temp))

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
        dplyr::mutate(month = tidyr::replace_na(month,1),
                      day = tidyr::replace_na(day,1),
                      tsunami = dplyr::if_else(is.na(tsunami), FALSE, TRUE),
                      volcano = dplyr::if_else(is.na(volcano), FALSE, TRUE)) %>%
        dplyr::mutate(offset = dplyr::if_else(year < 0, abs(year), 0),
                      .before = year) %>%
        dplyr::mutate(year = stringr::str_pad(dplyr::if_else(year < 0, 0, year), 4, pad = "0"),
                      month = stringr::str_pad(month, 2, pad = "0"),
                      day = stringr::str_pad(day, 2, pad = "0"),
                      hour = stringr::str_pad(hour, 2, pad = "0"),
                      minute = stringr::str_pad(minute, 2, pad = "0"),
                      second = stringr::str_pad(second, 2, pad = "0")) %>%
        dplyr::mutate(date = lubridate::ymd(paste(year,month,day,sep = "-")) - lubridate::years(offset),
                      .before = offset)
}

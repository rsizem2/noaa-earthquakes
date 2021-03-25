# Define global variables

utils::globalVariables(c("COUNTRY","DAY","Dy","HOUR","Hr","LOCATION","MINUTE",
                         "MONTH","Mn","Mo","OFFSET","REGION","SECOND","Sec",
                         "TSUNAMI","Tsu","VOLCANO","Vol","YEAR","Year"))


#' Reads in the raw data from the `inst/extdata` directory. Renames some columns, drops some irrelevant columns and converts all column names to uppercase.
#'
#' @return dataframe
#'
#' @param filename path to datafile
#'
#' @importFrom readr read_tsv
#' @importFrom magrittr %>%
#' @importFrom dplyr rename select slice n
#'
#' @examples
#'
#' \dontrun{
#'
#' # Retrieve all earthquake data from 2020
#' data <- eq_read_data() %>%
#'            dplyr::filter(YEAR == 2020)
#' }
#'
#' @export

eq_read_data <- function(filename = system.file("extdata","earthquakes-2021-03-08_17-02-58_-0500.tsv",
                                                package = "earthquakes")){
    data <- readr::read_tsv(filename) %>%
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
    data <- data %>% dplyr::select(-dplyr::contains("DESCRIPTION"))
}

#' Formats the LOCATION column correctly, removing redundant COUNTRY/REGION information.
#'
#' @return dataframe
#'
#' @param data dataframe object
#'
#' @importFrom stringr str_locate str_split
#' @importFrom magrittr %>%
#' @importFrom dplyr as_tibble mutate select if_else
#'
#' @examples
#'
#' \dontrun{
#'
#' # Retrieve all earthquake data for Japan since 2000
#' data <- eq_read_data() %>%
#'            filter(COUNTRY == "JAPAN", YEAR >= 2000)
#' }
#'
#' @export

eq_location_clean <- function(data = NULL){
    if(is.null(data)){
        data <- eq_read_data()
    }
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
#' @examples
#'
#' \dontrun{
#'
#' # Clean data and filter out entries with no TOTAL_DEATHS data
#' data <- eq_clean_data() %>%
#'     dplyr::filter(!is.na(TOTAL_DEATHS)) %>%
#'     dplyr::select(DATE, YEAR, COUNTRY, REGION, LONGITUDE, LATITUDE, MAG, TOTAL_DEATHS) %>%
#'     tidyr::drop_na()
#' }
#'
#'
#' @export

eq_clean_data <- function(rawdata = NULL){
    if(is.null(rawdata)){
        rawdata <- eq_location_clean()
    }
    rawdata <- rawdata %>%
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

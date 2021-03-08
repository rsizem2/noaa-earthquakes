
<!-- README.md is generated from README.Rmd. Please edit that file -->

# README

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/rsizem2/noaa-earthquakes.svg?branch=master)](https://travis-ci.com/rsizem2/noaa-earthquakes)
<!-- badges: end -->

This repository contains an R package for working with data from the
[NCEI/WDS Global Significant Earthquake
Database](https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/search).
This package is a work in progress and not ready for use at the moment.

# Installation

``` r
library(devtools)
install_github("rizem2/noaa-earthquakes")
```

# Reading Data

``` r
library(earthquakes)
data <- eq_clean_data()
head(data)
```

## Library Setting

library(tidyverse)
library(readr)
library(rjags)
library(rnoaa)
library(daymetr)
library(ecoforecastR)
library(neonUtilities)
library(raster)

#source("/Users/niabartolucci/Dropbox/My Mac (Nia’s MacBook Pro)/Desktop/Classes Spring 2021/Ecological Forecasting/EF_Activities/ecoforecastR/R/utils.R")

basePath <- getwd()
graphPath <- paste0(basePath,"/graph/")
dataPath <- paste0(basePath,"/data/")

#check directory existance
if (file.exists(graphPath)){
} else {
  dir.create(file.path(graphPath))
}

if (file.exists(dataPath)){
} else {
  dir.create(file.path(dataPath))
}

base_dir <- paste0(basePath,"/drivers/noaa/NOAAGEFS_1hr")
local_directory <- paste0(basePath,"/drivers/")

#check drivers directory exist
if (file.exists(local_directory)){
} else {
  dir.create(file.path(local_directory))
}
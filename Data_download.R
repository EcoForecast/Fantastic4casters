## Update data daily using cron
# This code is based on "Milestone4_Data_download.Rmd" 
# setting the terrestral data script to run at 5:00 AM daily

basePath <- "~/Ecological_Forecast/Fantastic4casters/"
graphPath <- "~/Ecological_Forecast/Fantastic4casters/graph/"
dataPath <- "~/Ecological_Forecast/Fantastic4casters/data/"

# Download target 30 min data

Target_30min<-readr::read_csv ("https://data.ecoforecast.org/targets/terrestrial/terrestrial_30min-targets.csv.gz")

# Save the updated target data as Rdata file

newFilename <- sprintf("%s.Rdata","Target_30min")
newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
save(Target_30min, file = newFilename)

# Plot 30min target data and export plot as pdf

newFilename <- sprintf("%s%s.pdf","Plot_Target_30min_",Sys.Date())
newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)
pdf(file = newFilename)
plot(Target_30min$time,Target_30min$nee, type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min$time,Target_30min$le, type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
dev.off()

# Download daily target data

Target_daily<-readr::read_csv("https://data.ecoforecast.org/targets/terrestrial/terrestrial_daily-targets.csv.gz")

# Save the updated target data as Rdata file

newFilename <- sprintf("%s.Rdata","Target_daily")
newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
save(Target_daily, file = newFilename)

# Plot daily target data and export plot as pdf

newFilename <- sprintf("%s%s.pdf","Plot_Target_Daily_",Sys.Date())
newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)
pdf(file = newFilename)
plot(Target_daily$time,Target_daily$nee, type="p", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily$time,Target_daily$le, type="p", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
dev.off()


# definition for directory, sites, date and cycles

base_dir <- "~/Ecological_Forecast/Fantastic4casters/drivers/noaa/NOAAGEFS_1hr"
site_names <- c("BART","KONZ","OSBS","SRER")
cycle_names <- c("00","06","12","18")

theDate <- Sys.Date()-1

## function for download NOAA meteorological prediction data

download_noaa_files_s3 <- function(siteID, date, cycle, local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}

### Setting function for converting the netcdf files to csv files

library(tidyverse)

noaa_gefs_read <- function(base_dir, date, cycle, sites){
  
  if(!(cycle %in% c("00","06","12","18"))){
    stop("cycle not available cycles of 00, 06,12,18")
  }
  
  cf_met_vars <- c("air_temperature",
                   "surface_downwelling_shortwave_flux_in_air",
                   "surface_downwelling_longwave_flux_in_air",
                   "relative_humidity",
                   "wind_speed",
                   "precipitation_flux")
  
  combined_met <- NULL
  
  for(i in 1:length(sites)){
    
    forecast_dir <- file.path(base_dir, sites[i], lubridate::as_date(date),cycle)
    
    forecast_files <- list.files(forecast_dir, full.names = TRUE)
    
    if(length(forecast_files) == 0){
      stop(paste0("no files in ", forecast_dir))
    }
    
    nfiles <-   length(forecast_files)
    
    for(j in 1:nfiles){
      
      ens <- dplyr::last(unlist(stringr::str_split(basename(forecast_files[j]),"_")))
      ens <- stringr::str_sub(ens,1,5)
      noaa_met_nc <- ncdf4::nc_open(forecast_files[j])
      noaa_met_time <- ncdf4::ncvar_get(noaa_met_nc, "time")
      origin <- stringr::str_sub(ncdf4::ncatt_get(noaa_met_nc, "time")$units, 13, 28)
      origin <- lubridate::ymd_hm(origin)
      noaa_met_time <- origin + lubridate::hours(noaa_met_time)
      noaa_met <- tibble::tibble(time = noaa_met_time)
      
      for(v in 1:length(cf_met_vars)){
        noaa_met <- cbind(noaa_met, ncdf4::ncvar_get(noaa_met_nc, cf_met_vars[v]))
      }
      
      ncdf4::nc_close(noaa_met_nc)
      
      names(noaa_met) <- c("time", cf_met_vars)
      
      noaa_met <- noaa_met %>% 
        dplyr::mutate(siteID = sites[i],
                      ensemble = as.numeric(stringr::str_sub(ens,4,5))) %>% 
        dplyr::select("siteID","ensemble","time",all_of(cf_met_vars))
      
      combined_met <- rbind(combined_met, noaa_met)
      
    }
  }
  return(combined_met)
}


# Download NOAA data for each sites (BART, KONZ, OSBS, SRER) and cycles (00,06,12,18)

for (i in 1:4){
  for (j in 1:4){
    download_noaa_files_s3(siteID = site_names[i], date = theDate, cycle = cycle_names[j], local_directory <- "~/Ecological_Forecast/Fantastic4casters/drivers")  
  }
}

# data conversion from cdf to csv, and plot data for ensemble 0 case as an example
for (j in 1:4){
  foo = noaa_gefs_read(base_dir, theDate, cycle_names[j], site_names)
  
  newFilename <- sprintf("%s%s%s%s.pdf","Plot_GEFS_30min_cycle",cycle_names[j],"_",Sys.Date()-1)
  newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)
  pdf(file = newFilename)
  for (i in 1:4){
    foo0 = subset(foo, ensemble==0 & siteID==site_names[i])
    plot(foo0$time, foo0$air_temperature, type='l', main = "air temperature prediction")
    plot(foo0$time, foo0$surface_downwelling_shortwave_flux_in_air, type='l', main = "shortwave flux prediction")
    plot(foo0$time, foo0$surface_downwelling_longwave_flux_in_air, type='l', main = "longwave flux prediction")
    plot(foo0$time, foo0$relative_humidity, type='l', main = "relative_humidity prediction")
    plot(foo0$time, foo0$wind_speed, type='l', main = "wind speed prediction")
    plot(foo0$time, foo0$precipitation_flux, type='l', main = "precipitation flux prediction")
  }
  dev.off()
}

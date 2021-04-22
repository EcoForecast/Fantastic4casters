#NOAA data load
# Download NOAA climate forecasts (hourly) and downsample to daily scale
download_noaa_files_s3 <- function(siteID, date, cycle="00", local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}
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
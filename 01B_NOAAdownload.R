## Update data using cron
# setting the terrestrial data script to run at 5:00 AM every 16th day

source("00C_Library+Directory_Setting.R")
library(zoo)

# definition for sites, date and cycles

site_names <- c("BART","KONZ","OSBS","SRER")
cycle_names <- "00"

theDate <- Sys.Date()-1
predict_month <- as.Date(as.yearmon(theDate))

## source function for download NOAA meteorological prediction data
### source setting function for converting the netcdf files to csv files

source("00B_NOAAconversion.R")


# Download NOAA data for each sites (BART, KONZ, OSBS, SRER) and cycles (we download only 00 cycle)

for (i in 1:4){
  download_noaa_files_s3(siteID = site_names[i], date = predict_month, cycle = cycle_names, local_directory <- paste0(basePath,"/drivers/"))
}

# data conversion from cdf to csv, and plot data for ensemble 0 case as an example
foo = noaa_gefs_read(base_dir, predict_month, cycle_names, site_names)

newFilename <- sprintf("%s%s%s%s.pdf","Plot_GEFS_30min_cycle",cycle_names,"_",Sys.Date()-1)
newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)
pdf(file = newFilename)
for (i in 1:4){
  foo0 = subset(foo, ensemble==1 & siteID==site_names[i])
  plot(foo0$time, foo0$air_temperature, type='l', main = "air temperature prediction")
  plot(foo0$time, foo0$surface_downwelling_shortwave_flux_in_air, type='l', main = "shortwave flux prediction")
  plot(foo0$time, foo0$surface_downwelling_longwave_flux_in_air, type='l', main = "longwave flux prediction")
  plot(foo0$time, foo0$relative_humidity, type='l', main = "relative_humidity prediction")
  plot(foo0$time, foo0$wind_speed, type='l', main = "wind speed prediction")
  plot(foo0$time, foo0$precipitation_flux, type='l', main = "precipitation flux prediction")
}
dev.off()


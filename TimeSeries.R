NEON_terrestrial<-readr::read_csv ("https://data.ecoforecast.org/targets/terrestrial/terrestrial_30min-targets.csv.gz")

Target_30min<-NEON_terrestrial[,c(1:4)]

plot(Target_30min$time,Target_30min$nee, type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min$time,Target_30min$le, type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")

Target_daily<-readr::read_csv("https://data.ecoforecast.org/targets/terrestrial/terrestrial_daily-targets.csv.gz")

plot(Target_daily$time,Target_daily$nee, type="p", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily$time,Target_daily$le, type="p", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")

summary(Target_30min)
summary(Target_daily)


#Meteorological Data
download_noaa_files_s3 <- function(siteID, date, cycle, local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}

#download all NOAA Global Ensemble Forecasting System (GEFS) data history (from Sep 25th, 2020 to Mar 5th, 2021)

site_names <- c("BART","KONZ","OSBS","SRER")
cycle_names <- c("00","06","12","18")
x = c(1:4)
y = c(1:4)

start <- as.Date("2020-09-25")
end <- as.Date("2021-03-05")

theDate <- start

while (theDate <= end)
{
  for (i in 1:4){
    for (j in 1:4){
      download_noaa_files_s3(siteID = site_names[i], date = theDate, cycle = cycle_names[j], local_directory <- "~/Ecological_Forecast/Fantastic4casters/drivers")  
    }}
  
  theDate <- theDate + 1
}



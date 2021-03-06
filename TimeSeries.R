NEON_terrestrial<-readr::read_csv ("https://data.ecoforecast.org/targets/terrestrial/terrestrial_30min-targets.csv.gz")

data<-NEON_terrestrial[,c(1:4)]

plot(data$time,data$nee, type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(data$time,data$le, type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")

dat2<-readr::read_csv("https://data.ecoforecast.org/targets/terrestrial/terrestrial_daily-targets.csv.gz")

summary(dat2)
summary(dat)


#Meteorological Data
download_noaa_files_s3 <- function(siteID, date, cycle, local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}

download_noaa_files_s3(siteID = "", date ="" , cycle = "00", local_directory <- "~/Dropbox/My Mac (Nia’s MacBook Pro)/Desktop/Classes Spring 2021/Ecological Forecasting")

## Update data daily using cron
# This code is based on "Milestone4_Data_download.Rmd" 
# setting the terrestral data script to run at 5:00 AM daily


basePath <- getwd()
graphPath <- paste0(basePath,"/graph/")
dataPath <- paste0(basePath,"/data/")
site_names <- c("BART","KONZ","OSBS","SRER")

library(tidyverse)
library(readr)


# Download target 30 min data

Target_30min<-readr::read_csv ("https://data.ecoforecast.org/targets/terrestrial/terrestrial_30min-targets.csv.gz",
                               col_types = cols(
                                 vswc = col_double(),
                                 vswc_sd = col_double())
)

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
plot(Target_30min$time,Target_30min$vswc, type="l", xlab = "Time", ylab = "Soil Moisture (%)")
dev.off()

# Download daily target data

Target_daily<-readr::read_csv("https://data.ecoforecast.org/targets/terrestrial/terrestrial_daily-targets.csv.gz",
                              col_types = cols(
                                time = col_date(format = ""),
                                siteID = col_character(),
                                nee = col_double(),
                                le = col_double(),
                                vswc = col_double(),
                                vswc_sd = col_double())
)

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
plot(Target_daily$time,Target_daily$vswc, type="l", xlab = "Time", ylab = "Soil Moisture (%)")
dev.off()


## Update data daily using cron
# This code is based on "Milestone4_Data_download.Rmd" 
# setting the terrestral data script to run at 5:00 AM daily

## Library + directory Setting (tidyverse, readr are required for this step)
source("00C_Library+Directory_Setting.R")

site_names <- c("BART","KONZ","OSBS","SRER")


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

Target_30min_BART = subset(Target_30min, siteID == 'BART') #subset data
Target_30min_KONZ = subset(Target_30min, siteID == 'KONZ')
Target_30min_OSBS = subset(Target_30min, siteID == 'OSBS')
Target_30min_SRER = subset(Target_30min, siteID == 'SRER')

newFilename <- sprintf("%s%s.pdf","Plot_Target_30min_",Sys.Date())
newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)
pdf(file = newFilename)
plot(Target_30min_BART$time,Target_30min_BART$nee, main="BART NEE 30min", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min_BART$time,Target_30min_BART$le, main="BART LE 30min", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_30min_BART$time,Target_30min_BART$vswc, main="BART Soil Moisture 30min", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_30min_KONZ$time,Target_30min_KONZ$nee, main="KONZ NEE 30min", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min_KONZ$time,Target_30min_KONZ$le, main="KONZ LE 30min", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_30min_KONZ$time,Target_30min_KONZ$vswc, main="KONZ Soil Moisture 30min", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_30min_OSBS$time,Target_30min_OSBS$nee, main="OSBS NEE 30min", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min_OSBS$time,Target_30min_OSBS$le, main="OSBS LE 30min", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_30min_OSBS$time,Target_30min_OSBS$vswc, main="OSBS Soil Moisture 30min", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_30min_SRER$time,Target_30min_SRER$nee, main="SRER NEE 30min", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_30min_SRER$time,Target_30min_SRER$le, main="SRER LE 30min", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_30min_SRER$time,Target_30min_SRER$vswc, main="SRER Soil Moisture 30min", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
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


Target_daily_BART = subset(Target_daily, siteID == 'BART') #subset data
Target_daily_KONZ = subset(Target_daily, siteID == 'KONZ')
Target_daily_OSBS = subset(Target_daily, siteID == 'OSBS')
Target_daily_SRER = subset(Target_daily, siteID == 'SRER')

newFilename <- sprintf("%s%s.pdf","Plot_Target_Daily_",Sys.Date())
newFilename <- paste(graphPath, newFilename, sep="", collapse = NULL)

pdf(file = newFilename)
plot(Target_daily_BART$time,Target_daily_BART$nee, main="BART NEE Daily", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily_BART$time,Target_daily_BART$le, main="BART LE Daily", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_daily_BART$time,Target_daily_BART$vswc, main="BART Soil Moisture Daily", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_daily_KONZ$time,Target_daily_KONZ$nee, main="KONZ NEE Daily", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily_KONZ$time,Target_daily_KONZ$le, main="KONZ LE Daily", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_daily_KONZ$time,Target_daily_KONZ$vswc, main="KONZ Soil Moisture Daily", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_daily_OSBS$time,Target_daily_OSBS$nee, main="OSBS NEE Daily", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily_OSBS$time,Target_daily_OSBS$le, main="OSBS LE Daily", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_daily_OSBS$time,Target_daily_OSBS$vswc, main="OSBS Soil Moisture Daily", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
plot(Target_daily_SRER$time,Target_daily_SRER$nee, main="SRER NEE Daily", type="l", xlab = "Time", ylab = "NEE(umol CO2 m-2 s-1)")
plot(Target_daily_SRER$time,Target_daily_SRER$le, main="SRER LE Daily", type="l", xlab = "Time", ylab = "Latent Heat Flux (W/m^2)")
plot(Target_daily_SRER$time,Target_daily_SRER$vswc, main="SRER Soil Moisture Daily", type="l", xlab = "Time", ylab = "Soil Moisture (%)")
dev.off()


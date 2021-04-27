
#title: "01C_COVdownload"
#author: "Nia Bartolucci; Cameron Reimer; Kangjoon Cho; Zhenpeng Zuo"
#date: "4/12/2021"
#output: html_document

  

# install neonUtilities install
#install.packages("neonUtilities") 
#install.packages('BiocManager')
#install,packages("raster")
#BiocManager::install('rhdf5')

options(stringsAsFactors = F)
ym <- format(Sys.Date(),"%Y-%m")

# load neonUtilities
source("00C_Library+Directory_Setting.R")

Tmp <- loadByProduct(dpID="DP1.00002.001", site=c("BART","KONZ","OSBS","SRER"),
                     startdate="2020-01", enddate=ym, check.size=F)
temp_data = Tmp[["SAAT_30min"]]

newFilename <- sprintf("%s.Rdata","Air_Temperature")
newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
save(temp_data, file = newFilename)

rm(Tmp,temp_data)

precip <- loadByProduct(dpID="DP1.00006.001", site=c("BART","KONZ","OSBS","SRER"),
                        startdate="2020-01", enddate=ym, check.size=F)
precip_data = precip[["PRIPRE_30min"]]
rm(precip)

newFilename <- sprintf("%s.Rdata","Precipitation")
newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
save(precip_data, file = newFilename)
rm(precip, precip_data)

swlw <- loadByProduct(dpID="DP1.00023.001", site=c("BART","KONZ","OSBS","SRER"),
                      startdate="2020-01", enddate=ym, check.size=F)
swlw_data = swlw[["SLRNR_30min"]]

newFilename <- sprintf("%s.Rdata","Radiance")
newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
save(swlw_data, file = newFilename)
rm(swlw,swlw_data)

#wind <- loadByProduct(dpID="DP1.00001.001", site=c("BART","KONZ","OSBS","SRER"),
#              startdate="2020-01", enddate=ym, check.size=F)
#
#newFilename <- sprintf("%s.Rdata","Wind")
#newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
#save(wind, file = newFilename)
#rm(wind)

#hum <- loadByProduct(dpID="DP1.00098.001", site=c("BART","KONZ","OSBS","SRER"),
#              startdate="2020-01", enddate=ym, check.size=F)
#newFilename <- sprintf("%s.Rdata","Humidity")
#newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
#save(hum, file = newFilename)
#rm(hum)

#baro <- loadByProduct(dpID="DP1.00004.001", site=c("BART","KONZ","OSBS","SRER"),
#              startdate="2020-01", enddate=ym, check.size=F)
#newFilename <- sprintf("%s.Rdata","Pressure")
#newFilename <- paste(dataPath, newFilename, sep="", collapse = NULL)
#save(baro, file = newFilename)
#rm(baro)


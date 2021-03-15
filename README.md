# Fantastic4casters 

2021 BU EE585 team project: EFI/NEON terrestrial carbon challenge 


## 0. Contact Information


Nia Bartolucci
barto22n@bu.edu

Cameron Reimer
cjreimer@bu.edu 

Kangjoon Cho
kangjoon@bu.edu

Zhenpeng Zuo
zpzuo@bu.edu


## 1. Pulling and visualizing data


For any current date, the R script named **"Data_download.R"** is used to pull NEON measurements (NEE, LE, and soil moisture) and NOAA weather forecasts (NOAA’s Global Ensemble Forecasting System, GEFS) across the four NEON sites, and to plot time series for the NEON history and the NOAA projections.

Before running, the variable **"base_dir"** at **Data_download.R** that defines the **working directory**, where the data are temporarily stored and output graphs saved, needs to be set manually. Additionally, the user should mannually create the directories on the local machine: the working directory, as well as "data", "graph", "drives" under the working directory. To schedule running the code on a daily basis, copy the following cron table in the Terminal and hit enter (`cron` is required, supported only on Unix-based operating systems): 


```


# [On terminal] crontab -e > i > Insert below code 

# setup the terrestral data script to run at 5:00 AM
MAILTO="kangjoon@bu.edu;barto22n@bu.edu;cjreimer@bu.edu;zpzuo@bu.edu"
00 05 * * * /usr/local/bin/Rscript/ "PATH/Data_download.R"


```


Of the data being pulled, the NEON measurements are updated monthly, with each update releasing new daily data for the past month. Therefore, for the daily runs, the plotted NEON historical time series will include data only up to the latest NEON release. For the NOAA weather forecasts, 35-day ensemble projections, making up of 31 ensembles, or forecasts by separate models, are released once per six hours at a 1-hour forecasting resolution.

The time series plots will be exported to the "graph" sub-directory under the main directory. 



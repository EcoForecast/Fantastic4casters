<<<<<<< HEAD
# Fantastic4casters
2021 BU EE585 team project: EFI/NEON terrestrial carbon challenge 


=======
# Fantastic4casters 

2021 BU EE585 team project: EFI/NEON terrestrial carbon challenge 

## 0. Contact Information
>>>>>>> 6f615ec9f660359aa48efe17008321b4ebbab484

Nia Bartolucci
barto22n@bu.edu

Cameron Reimer
Email: cjreimer@bu.edu 

Kangjoon Cho
Email: kangjoon@bu.edu

Zhenpeng Zuo
Email: zpzuo@bu.edu



<<<<<<< HEAD
=======
## 1. Pulling and visualizing data

For any current date, the R script named **"XXX.R"** is used to pull NEON measurements (NEE, LE, and soil moisture) and NOAA weather forecasts (NOAA’s Global Ensemble Forecasting System, GEFS) across the four NEON sites, and to plot time series for the NEON history and the NOAA projections. 

Before running, the variable **"XXX"**  at line **X** of **XXX.R** that defines the **working directory**, where the data are temporarily stored and output graphs saved, needs to be set manually. To schedule running the code on a daily basis, copy the following cron table in the Terminal and hit enter (`cron` is required, supported only on Unix-based operating systems): 

```

```

Of the data being pulled, the NEON measurements are updated monthly, with each update releasing new daily data for the past month. Therefore, for the daily runs, the plotted NEON historical time series will include data only up to the latest NEON release. For the NOAA weather forecasts, 35-day ensemble projections, making up of 31 ensembles, or forecasts by separate models, are released once per six hours at a 1-hour forecasting resolution. Among the four NOAA updates for any single day, we only take the first cycle, labeled "00", as the representative of the day. 

The pulled data and the sub-directories created for storing the data are automatically deleted before the program exits. Only the output graphs are retained. 
>>>>>>> 6f615ec9f660359aa48efe17008321b4ebbab484


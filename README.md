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

## 2. Historical time-series fit

Before generating forecasts, use scripts named "**XXX**" to fit the historical data. For this historical fit of NEE, LE, and soil moisture, we created a joint, state-space, dynamic linear model which include data models and process models. The data models are inspired from simple Gaussian distributions,

<img src="https://latex.codecogs.com/svg.image?\begin{aligned}NEE_{obs}[t]&space;&&space;\sim&space;N(NEE[t],&space;\tau_{NEE_{obs}})\\LE_{obs}[t]&space;&&space;\sim&space;N(LE[t],&space;\tau_{LE_{obs}})&space;\\SM_{obs}[t]&space;&&space;\sim&space;N(SM[t],&space;\tau_{SM_{obs}})\end{aligned}" title="\begin{aligned}NEE_{obs}[t] & \sim N(NEE[t], \tau_{NEE_{obs}})\\LE_{obs}[t] & \sim N(LE[t], \tau_{LE_{obs}}) \\SM_{obs}[t] & \sim N(SM[t], \tau_{SM_{obs}})\end{aligned}" />

where <img src="https://latex.codecogs.com/svg.image?\inline&space;NEE" title="\inline NEE" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;LE" title="\inline LE" />, and <img src="https://latex.codecogs.com/svg.image?\inline&space;SM" title="\inline SM" /> are the targets for our forecasting, <img src="https://latex.codecogs.com/svg.image?\inline&space;t" title="\inline t" /> represents time, and <img src="https://latex.codecogs.com/svg.image?\inline&space;\tau" title="\inline \tau" />'s (given by normal distributions, see below) represent the uncertainties during observation and/or data collection. The subscript <img src="https://latex.codecogs.com/svg.image?\inline&space;obs" title="\inline obs" /> represents the observed value of the variables. 

The process model includes shortwave radiance, longwave radiance, air temperature, and precipitation as covariates. It also makes NEE, LE, and soil moisture intercorrelated. 

<img src="https://latex.codecogs.com/svg.image?\begin{aligned}NEE[t]&space;&\sim&space;N(\mu_{NEE}[t],\tau_{NEE_{add}})&space;\\LE[t]&space;&\sim&space;N(\mu_{LE}[t],\tau_{LE_{add}})&space;\\SM[t]&space;&\sim&space;N(\mu_{SM}[t],\tau_{SM_{add}})&space;\\\mu_{NEE}[t]&space;&=&space;\beta_{NEE}\cdot&space;NEE[t-1]&space;&plus;&space;\beta_{NEE,LE}\cdot&space;LE[t-1]&space;&plus;&space;\\&&space;\beta_{NEE,SM}\cdot&space;SoilMois[t-1]&space;&plus;&space;\beta_{NEEI}\cdot&space;XfI[t,1]&space;&plus;&space;\\&&space;\beta_{NEE,sw}\cdot&space;XfC[t,1]&space;&plus;&space;\beta_{temp}\cdot&space;XfC[t,3]&space;\\\mu_{LE}[t]&space;&=&space;\beta_{LE}\cdot&space;LE[t-1]&space;&plus;&space;\beta_{LE,NEE}\cdot&space;NEE[t-1]&space;&plus;&space;\\&&space;\beta_{LE,SM}\cdot&space;SM[t-1]&space;&plus;&space;\beta_{LEI}\cdot&space;XfI[t,2]&space;&plus;&space;\\&&space;\beta_{LE,sw}\cdot&space;XfC[t,1]&space;&plus;&space;\beta_{lw}\cdot&space;XfC[t,2]&space;\\\mu_{SM}[t]&space;&=&space;\beta_{SM}\cdot&space;SM[t-1]&space;&plus;&space;\beta_{SM,NEE}\cdot&space;NEE[t-1]&space;&plus;&space;\\&&space;\beta_{SM,LE}\cdot&space;LE[t-1]&space;&plus;&space;\beta_{SMI}\cdot&space;XfI[t,3]&space;&plus;&space;\\&&space;\beta_{precip}\cdot&space;XfC[t,4]&space;\\XfI[t,i]&space;&\sim&space;N(\mu_{XfI}[i],\tau_{XfI}[i])&space;\\XfC[t,i]&space;&\sim&space;N(\mu_{XfC}[i],\tau_{XfC}[i])\end{aligned}" title="\begin{aligned}NEE[t] &\sim N(\mu_{NEE}[t],\tau_{NEE_{add}}) \\LE[t] &\sim N(\mu_{LE}[t],\tau_{LE_{add}}) \\SM[t] &\sim N(\mu_{SM}[t],\tau_{SM_{add}}) \\\mu_{NEE}[t] &= \beta_{NEE}\cdot NEE[t-1] + \beta_{NEE,LE}\cdot LE[t-1] + \\& \beta_{NEE,SM}\cdot SoilMois[t-1] + \beta_{NEEI}\cdot XfI[t,1] + \\& \beta_{NEE,sw}\cdot XfC[t,1] + \beta_{temp}\cdot XfC[t,3] \\\mu_{LE}[t] &= \beta_{LE}\cdot LE[t-1] + \beta_{LE,NEE}\cdot NEE[t-1] + \\& \beta_{LE,SM}\cdot SM[t-1] + \beta_{LEI}\cdot XfI[t,2] + \\& \beta_{LE,sw}\cdot XfC[t,1] + \beta_{lw}\cdot XfC[t,2] \\\mu_{SM}[t] &= \beta_{SM}\cdot SM[t-1] + \beta_{SM,NEE}\cdot NEE[t-1] + \\& \beta_{SM,LE}\cdot LE[t-1] + \beta_{SMI}\cdot XfI[t,3] + \\& \beta_{precip}\cdot XfC[t,4] \\XfI[t,i] &\sim N(\mu_{XfI}[i],\tau_{XfI}[i]) \\XfC[t,i] &\sim N(\mu_{XfC}[i],\tau_{XfC}[i])\end{aligned}" />

where <img src="https://latex.codecogs.com/svg.image?\inline&space;\mu" title="\inline \mu" />'s are means of the normal distributions and <img src="https://latex.codecogs.com/svg.image?\inline&space;\tau" title="\inline \tau" />'s define uncertainties, with the subscript <img src="https://latex.codecogs.com/svg.image?\inline&space;add" title="\inline add" /> indicating the model's iteration over time <img src="https://latex.codecogs.com/svg.image?\inline&space;t" title="\inline t" />. For deriving each <img src="https://latex.codecogs.com/svg.image?\inline&space;\mu" title="\inline \mu" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;\beta" title="\inline \beta" />'s are coefficients for the terms, including the last step of the variable and the other variables, intercepts <img src="https://latex.codecogs.com/svg.image?\inline&space;XfI" title="\inline XfI" />, and the corresponding covariates <img src="https://latex.codecogs.com/svg.image?\inline&space;XfC" title="\inline XfC" />. Incoming shortwave radiation (<img src="https://latex.codecogs.com/svg.image?\inline&space;sw" title="\inline sw" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;XfC[:,1]" title="\inline XfC[:,1]" />) and temperature (<img src="https://latex.codecogs.com/svg.image?\inline&space;temp" title="\inline temp" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;XfC[:,3]" title="\inline XfC[:,3]" />) are selected as covariates for NEE, <img src="https://latex.codecogs.com/svg.image?\inline&space;sw" title="\inline sw" /> and incoming longwave radiation (<img src="https://latex.codecogs.com/svg.image?\inline&space;lw" title="\inline lw" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;XfC[:,2]" title="\inline XfC[:,2]" />) for LE, and precipitation (<img src="https://latex.codecogs.com/svg.image?\inline&space;precip" title="\inline precip" />, <img src="https://latex.codecogs.com/svg.image?\inline&space;XfC[:,4]" title="\inline XfC[:,4]" />) for SM. 

Priors used for the data models and the process model are 

<img src="https://latex.codecogs.com/svg.image?\begin{aligned}NEE[1]&space;&\sim&space;N(0,0.00001)&space;\\LE[1]&space;&\sim&space;N(0,0.00001)&space;\\SM[1]&space;&\sim&space;N(0,0.00001)&space;\\\end{aligned}" title="\begin{aligned}NEE[1] &\sim N(0,0.00001) \\LE[1] &\sim N(0,0.00001) \\SM[1] &\sim N(0,0.00001) \\\end{aligned}" />

<img src="https://latex.codecogs.com/svg.image?\begin{aligned}\tau_{NEE_{obs}}&space;&\sim&space;\Gamma(3,1)&space;\\\tau_{LE_{obs}}&space;&\sim&space;\Gamma(0.5,1)&space;\\\tau_{SM_{obs}}&space;&\sim&space;\Gamma(0.1,0.1)&space;\\\tau_{NEE_{add}}&space;&\sim&space;\Gamma(3,1)&space;\\\tau_{LE_{add}}&space;&\sim&space;\Gamma(0.1,0.1)&space;\\\tau_{SM_{add}}&space;&\sim&space;\Gamma(0.1,0.1)&space;\\\end{aligned}" title="\begin{aligned}\tau_{NEE_{obs}} &\sim \Gamma(3,1) \\\tau_{LE_{obs}} &\sim \Gamma(0.5,1) \\\tau_{SM_{obs}} &\sim \Gamma(0.1,0.1) \\\tau_{NEE_{add}} &\sim \Gamma(3,1) \\\tau_{LE_{add}} &\sim \Gamma(0.1,0.1) \\\tau_{SM_{add}} &\sim \Gamma(0.1,0.1) \\\end{aligned}" />

<img src="https://latex.codecogs.com/svg.image?\begin{aligned}\beta_{all}&space;&&space;\sim&space;N(0,0.001)&space;\\\mu_{XFI}[i]&space;&\sim&space;N(0,0.001)&space;\\\mu_{XfC}[i]&space;&\sim&space;N(0,0.001)&space;\\\tau_{XfI}[i]&space;&\sim&space;N(0.01,0.01)&space;\\\tau_{XfC}[i]&space;&\sim&space;N(0.01,0.01)\end{aligned}" title="\begin{aligned}\beta_{all} & \sim N(0,0.001) \\\mu_{XFI}[i] &\sim N(0,0.001) \\\mu_{XfC}[i] &\sim N(0,0.001) \\\tau_{XfI}[i] &\sim N(0.01,0.01) \\\tau_{XfC}[i] &\sim N(0.01,0.01)\end{aligned}" />

The model was run with JAGS (Just Another Gibbs Sampler), a statistical software package designed to do Bayesian analyses using Markov Chain Monte Carlo (MCMC) numerical simulation methods, for 20,000 iterations with three chains. The burn-in period is determined to be the first 500 steps of iteration, and is removed in subsequent analyses. 

## 3. Ensemble forecast


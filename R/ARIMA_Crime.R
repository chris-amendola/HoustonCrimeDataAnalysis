# Title:  ARIMA: Auto-regressive Integrated Moving Average

# INSTALL AND LOAD PACKAGES ################################
pacman::p_load(  # Use p_load function from pacman
  datasets,      # R's built-in sample datasets
  forecast,      # Time series analysis
  ggfortify,     # Time series graphing
  changepoint,   # Changepoint analysis
  magrittr,      # Pipes
  pacman,        # Load/unload packages
  rio,           # Import/export data
  tidyverse      # So many reasons
)

# Set random seed for reproducibility in processes like
# splitting the data. You can use any number.
set.seed(1)

# LOAD AND PREPARE DATA ####################################
## Overall Violent
crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,NIBRSDescription:='Violent Incidents']

DT<-crimes_filtered[,.(OffenseCount=sum(OffenseCount)),by=(year_mon)]%>%
  .[order(year_mon)]%>%
  .[,Rolling_12_Month:=frollapply(OffenseCount,12,mean),]%>%
  .[order(year_mon)]


mo <- as.numeric(format(DT$year_mon[1], "%m"))
yr <- as.numeric(format(DT$year_mon[1], "%Y"))
df<-ts(DT$OffenseCount, start = c(yr, mo), freq = 12)


# Plot data
df%>% 
  plot(
    main = "Main",
    ylim=c(0,2700),
    xlab = "Year: 2019-2023",
    ylab = "Monthly Violent Incidents"
  )
# DECOMPOSE TIME SERIES ####################################

# Uses the `decompose` function from R's built-in `stats`
# package; default method is "additive"
df %>% 
  decompose() %>%
  plot()

# Can also specify a multiplicative trend, which is good for
# trends that spread over time; the scales for the seasonal
# and random components are now multipliers instead of
# addends.
df %>% 
  decompose(
    type = "multiplicative"
  ) %>%
  plot()


# TEST STATIONARITY ########################################

# ARIMA requires non-stationary data. That is, ARIMA needs
# data where means that the mean, the variance, and/or the
# covariance vary over time. Non-stationary data shows
# significant correlations when lagged. A "correlogram"
# graph shows the degree of correlation at different values
# of lag. Ideally, none of the lag values will fall in the
# range of non-significant correlations.
df %>% acf()

# LINEAR MODEL #############################################

# Graph time series using with linear regression line; the 
# `autoplot` functions helps ggplot2 work well with many 
# kinds of data, including time-series data
df %>% 
  autoplot() +
  geom_smooth(      # Add a trend line
    method = "lm",  # Use linear regressions
    aes(y = value)  # Predict `value` in time-series
  ) +
  labs(
    x = "Year",
    y = "Monthly Violent Incidents",
    title = "Violent Incidents"
  )

# MODEL DATA ###############################################

# Test auto ARIMA to have the best p, q, d parameters
df %>% auto.arima()

# auto.arima suggests ARIMA(1,1,0)(0,1,0)[12] 
# First set of numbers is for the basic, non-seasonal model
#   1    # p: Auto-regressive (AR) order
#   1    # d: Integrate (I), or degree of differencing
#   0    # q: Moving average (MA) order
# Second set of numbers is for seasonality
#   0    # P: Auto-regressive (AR) order
#   1    # D: Integrate (I), or degree of differencing
#   0    # Q: Moving average (MA) order
# Number in square brackets (usually written as subscript)
#   12:  # M: Model period or seasonality

# See the diagnostic plots: standardized residuals, ACF 
# (autocorrelation function) of residuals, and the Ljung-Box
# test for autocorrelations
df %>% 
  auto.arima() %>%
  ggtsdiag()

# CHANGEPOINTS ############################################

# Compute and plot time series with change points; can look
# for changepoints in mean using `cpt.mean()`, in variance
# with `cpt.var()`, or both with `cpt.meanvar()`.
df %>%
  cpt.mean(
    test.stat = "Normal"
  ) %T>%                  # T-pipe
  plot(                   # Add change point lines to plot
    cpt.width = 3,        # Line width
    main = "Change Points",
    xlab = "Year"
  ) %>% 
  cpts.ts()               # Print change point location(s)


# CLEAN UP #################################################

# Clear data
rm(list = ls())  # Removes all objects from the environment

# Clear packages
detach("package:datasets", unload = T)  # For base packages
p_unload(all)  # Remove all contributed packages

# Clear plots
graphics.off()  # Clears plots, closes all graphics devices

# Clear console
cat("\014")  # Mimics ctrl+L

# Clear R
#   You may want to use Session > Restart R, as well, which 
#   resets changed options, relative paths, dependencies, 
#   and so on to let you start with a clean slate

# Clear mind :)

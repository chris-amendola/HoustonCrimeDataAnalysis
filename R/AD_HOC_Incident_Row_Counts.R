#https://help.healthycities.org/hc/en-us/articles/233420187-Mann-Kendall-test-for-trend-overview

setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/October2023')

# By Year-Month
data<-multi_year[year>2019,.(nrows=.N),by=c('year_mon')]

data[,.(max(nrows))]

library(ggplot2)
library(hrbrthemes)
# Basic scatter plot.
p1 <- ggplot(data, aes(x=year_mon, y=nrows)) + 
  geom_point( color="#69b3a2") +
  theme_ipsum()
p1
# with linear trend
p2 <- ggplot(data, aes(x=year_mon, y=nrows)) +
  geom_point() +
  geom_smooth(method=lm , color="red", se=FALSE) +
  theme_ipsum()
p2
# linear trend + confidence interval
p3 <- ggplot(data, aes(x=year_mon, y=nrows)) +
  geom_point() +
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  theme_economist()+ylim(0,22500)+
  theme(plot.title = element_text(hjust = 0.0))+
  ylab('Numbers of Incidents Reported')+
  xlab('Year-Month')+
  labs(title = "Counts of Incidents Reported by Year-Month", tag = "1")
p3

library(Kendall)

MannKendall(data$nrows)

# No Trend
# tau = 0.143, 2-sided pvalue =0.1678
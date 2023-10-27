crimes_filtered<-multi_year[NIBRSDescription=='Driving under the influence']

data<-crimes_filtered[,.(freq=sum(OffenseCount)),by=c('year_mon')]

library(ggplot2)

library(hrbrthemes)

# Basic scatter plot.
p1 <- ggplot(data, aes(x=year_mon, y=freq)) + 
  geom_point( color="#69b3a2") +
  theme_ipsum()+ylim(0, 850)
p1
# with linear trend
p2 <- ggplot(data, aes(x=year_mon, y=freq)) +
  geom_point() +
  geom_smooth(method=lm , color="red", se=FALSE) +
  theme_ipsum()+ylim(0, 850)
p2
# linear trend + confidence interval
p3 <- ggplot(data, aes(x=year_mon, y=freq)) +
  geom_point() +
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  theme_ipsum()+ylim(0, 850)
p3
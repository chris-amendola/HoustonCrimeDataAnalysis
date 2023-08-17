library(readr)
VC_RATE_data<-read_delim("~/Random_Nextdoor/ShopLifting/VC_RATE_data.txt", 
                           delim = "\t", escape_double = FALSE, 
                           trim_ws = TRUE)%>%
              mutate(diff=abs(RATE-lag(RATE,default=first(RATE))))%>%
              mutate(z=(mean(VC_RATE_data$diff)-diff)/sd(VC_RATE_data$diff))


library(readr)
library(data.table)

data<-fread("C:/Users/chris/Downloads/Percent of violent crime excluding simple assault victimizations by victim-offender relationship, 2021 vs. 2022.csv")
data$Number<-as.integer(gsub(",", "",data$Number))

exp_prp<-data[Year==2021,.(exp_p=Number/sum(Number))]
obs_cts<-data[Year==2022,.(Number)]

chisq.test(x=obs_cts[[1]], p=exp_prp[[1]])

exp_cts<-exp_prp*data[Year==2022,.(sum(Number))][[1]]

((obs_cts-exp_cts)^2)/exp_cts
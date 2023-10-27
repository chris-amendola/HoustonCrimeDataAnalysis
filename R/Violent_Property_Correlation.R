

## Overall Property
property<-multi_year[NIBRSDescription %chin% property_crimes]%>%
  .[,.(PropertyCount=sum(OffenseCount)),by=(year_mon)]%>%
  .[,Property_Rolling_12:=frollapply(PropertyCount,12,mean),]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

## Overall Violent
violent<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,.(ViolentCount=sum(OffenseCount)),by=(year_mon)]%>%
  .[,Violent_Rolling_12:=frollapply(ViolentCount,12,mean),]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']


compare<-property[violent,on=('year_mon')]

compare$PropertyChange<-compare$PropertyCount-lag(compare$PropertyCount,n=1)
compare$ViolentChange<-compare$ViolentCount-lag(compare$ViolentCount,n=1)

compare$PropertyChange_roll<-compare$Property_Rolling_12-lag(compare$Property_Rolling_12,n=1)
compare$ViolentChange_roll<-compare$Violent_Rolling_12-lag(compare$Violent_Rolling_12,n=1)

cor.test( compare$PropertyChange_roll
    ,compare$ViolentChange_roll
    ,method = c("pearson", "kendall", "spearman")
    , use = "complete.obs")

#--Significant, moderate negative correlation--
# data:  compare$PropertyChange_roll and compare$ViolentChange_roll
# t = -2.7149, df = 42, p-value = 0.009578
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
#  -0.6129548 -0.1011042
# sample estimates:
#  cor 
# -0.3863868


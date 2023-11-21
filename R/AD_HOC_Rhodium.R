#Rhodium
Rhodium_Price_Data_wide<-fread( glue("{support_dir}Rhodium_Price_Data.csv")
                          ,header=TRUE)

Rhodium_Price_Data<-melt( Rhodium_Price_Data_wide
     ,measure.vars=c("2019","2020","2021","2022","2023")
     ,id.vars= c("Month"))

Rhodium_Price_Data$year_mon<-as.POSIXct(paste0( Rhodium_Price_Data$variable,"-"
                                          ,Rhodium_Price_Data$Month,"-"
                                          ,1),tz = "UTC")

Rhodium_Price_Data$Rhodium_12_Month<-frollapply(Rhodium_Price_Data$value,12,mean)

ggplot( data=Rhodium_Price_Data[year_mon>'2019-12-01']
       , aes(x=year_mon,y=Rhodium_12_Month))+
  geom_line(linewidth=1, alpha=0.9, linetype=1)+
  scale_color_manual(values=c('darkblue'))+
  ggtitle(glue('Rhodium Price Trends'))+
  theme_economist()+
  theme(legend.key = element_rect(colour = "black"))+
  theme(plot.title = element_text(hjust = 0.0))+ 
  ylab("Rhodium Price")


#Catalytic Theft
crimes_filtered<-multi_year[NIBRSDescription=='Theft of motor vehicle parts or accessory']

data<-crimes_filtered[,.(OffenseCount=sum(OffenseCount)),by=(year_mon)]%>%
  .[order(year_mon)]%>%
  .[,CC_Theft_12_Month:=frollapply(OffenseCount,12,mean),]%>%
  .[order(year_mon)]%>%
  .[year_mon>'2019-12-01']

ggplot( data=data
        , aes(x=year_mon,y=CC_Theft_12_Month))+
  geom_line(linewidth=1, alpha=0.9, linetype=1)+
  scale_color_manual(values=c('red'))+
  ggtitle(glue('Theft of motor vehicle parts or accessory Incident Trends'))+
  theme_economist()+
  theme(legend.key = element_rect(colour = "black"))+
  theme(plot.title = element_text(hjust = 0.0))+ 
  ylab("Theft of motor vehicle parts or accessory")

#Compare
df<-Rhodium_Price_Data[data,on=c('year_mon')]%>%
   .[,c('year_mon','Rhodium_12_Month','CC_Theft_12_Month')]

df$Rhodium_Price <-(df$Rhodium_12_Month - mean(df$Rhodium_12_Month)) / sd(df$Rhodium_12_Month) 
df$CC_Theft<-(df$CC_Theft_12_Month - mean(df$CC_Theft_12_Month)) / sd(df$CC_Theft_12_Month) 
df<-melt( df
        ,measure.vars=c("Rhodium_Price","CC_Theft")
        ,id.vars= c("year_mon")
        ,variable.name='Legend')

ggplot(data=df, aes(x=year_mon,y=value, group=Legend,color=Legend))+
  geom_line(linewidth=1, alpha=0.9, linetype=1)+
  scale_color_manual(values=c('darkblue', 'red'))+
  ggtitle(glue('Comparison of Rhodium Price Trends to Catalytic Converter Theft Trends'))+
  theme_economist()+
  theme(legend.key = element_rect(colour = "black"))+
  theme(plot.title = element_text(hjust = 0.0))+ 
  ylab("Scaled Trend")

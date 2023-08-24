

NIBRS_Trend<- function( indata
                       ,title1='title1') {

  data<-indata[,.(OffenseCount=sum(OffenseCount)),by=(year_mon)]%>%
        .[,Rolling_12_Month:=frollapply(OffenseCount,12,mean),]%>%
        .[order(year_mon)]%>%
        .[year_mon>'2019-12-01']
  
  start_val<-round(data[year_mon==min(year_mon)][[1,3]],2)
  max_value<-round(data[Rolling_12_Month==max(Rolling_12_Month)][[1,3]],2)
  max_mon<-data[Rolling_12_Month==max(Rolling_12_Month)][[1,1]]
  min_value<-round(data[Rolling_12_Month==min(Rolling_12_Month)][[1,3]],2)
  end_value<-round(data[year_mon==max(year_mon)][[1,3]],2)
  
  return(ggplot(data=data, aes(x=year_mon, y=Rolling_12_Month, group=1))+
        ggtitle(glue('{title1}\n\rOverall'))+
        geom_line(color="darkblue", linewidth=1, alpha=0.9, linetype=1)+
        geom_hline(yintercept=start_val, linetype="dashed", color = "darkgreen")+
        geom_hline(yintercept=end_value, linetype="dashed", color = "red")+
        geom_hline(yintercept=max_value, linetype="dashed", color = "blue")+
        theme_economist()+
        theme(legend.key = element_rect(fill = "grey", colour = "black"))+
        theme(plot.title = element_text(hjust = 0.0))+
        ylab("Rolling 12 Month Average"))
}

#NIBRS_Trend(crimes_filtered,'Violent')
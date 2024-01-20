library(ggrepel)
library(gt)

z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}
perc_change<-function(current,historical){
  
  return(  round( ( ((current-historical)/historical)*100.00
  ),2) )    
}


crimes_filtered<-multi_year[NIBRSDescription=='Shoplifting']

icrime<-'Shoplifting'

NIBRS_Trend(indata=crimes_filtered,'Shoplifting')
NIBRS_YTD(indata=crimes_filtered,'Shoplifting',latest_mon='10')

# Test Premise Changes
pri_yr<-2022
cur_yr<-2023
latest_mon<-10

pri_end_dt<-eom(latest_mon,pri_yr)
cur_end_dt<-eom(latest_mon,cur_yr)


crimes_YTD<-crimes_filtered%>%
  .[ ( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
       &RMSOccurrenceDate<=as.Date(cur_end_dt))
     |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
        &RMSOccurrenceDate<=as.Date(pri_end_dt)) 
     ,.(Freq=sum(OffenseCount))
     ,by=c('Premise','year')]


wide_yr<-dcast( crimes_YTD
                ,Premise~year
                ,value.var = "Freq")

#wide_yr$`2023`<-wide_yr$`2023`*.952

wide_yr$z_poi<-z_poi(wide_yr$`2023`,wide_yr$`2022`)
wide_yr$Percent_Change<-perc_change(wide_yr$`2023`,wide_yr$`2022`)
wide_yr$Difference<-wide_yr$`2023`-wide_yr$`2022`

wide_yr<-wide_yr[,Label:=fcase( z_poi<=-3
                                ,"DOWN"
                                ,z_poi>=3
                                ,"UP"
                                ,default="No Change")]

wide_yr<-wide_yr[,Change:=fcase( z_poi<=-3
                                 ,md("**")
                                 ,z_poi>=3
                                 ,md("**")
                                 ,default=md("--"))]

wide_yr$Percent_Change<-paste0(wide_yr$Percent_Change,' ',wide_yr$Change)

wide_yr[order(-z_poi)]%>%.[,.(Premise,`2022`,`2023`,Difference,Percent_Change)]%>%
  gt(rowname_col = "Premise")%>%
  fmt_number( columns=c(`2022`,`2023`,`Difference`)
              ,decimals=0
              ,use_seps=TRUE)%>%
  tab_header( title='Shoplifting Standardized Report - Details'
              ,subtitle=md('**YTD Incidents(Jan-Oct 2022 vs 2023)**'))%>%
  cols_label( Premise=md("**Premise**")
              ,Percent_Change=md("**% Change**"))%>%
  tab_footnote(
    footnote = "** Indicates Change is beyond expected variation",
    locations = cells_column_labels(columns = Percent_Change)
  )%>%
  tab_footnote(
    footnote = "-- Indicates Change is consistent with expected variation",
    locations = cells_column_labels(columns = Percent_Change)
  )


# Address work
dd_agg<-crimes_filtered[year==2022,.(FREQ=sum(OffenseCount))
                   ,by=c( 'StreetNo'
                          ,'StreetName'
                          ,'StreetType'
                          ,'year')]
                          #,'Premise')]

print('Offense Count: ')
print(sum(dd_agg$FREQ))
print('Distinct Addresses:')
nrow(dd_agg)
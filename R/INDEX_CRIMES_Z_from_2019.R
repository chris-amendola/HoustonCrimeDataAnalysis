library(gt)
library(htmlwidgets)
setwd('C:/Users/chris/Documents/Houston_Crime_Data_Analysis/November2023')

z_poi<-function(current,historical){
  
  return(2*(sqrt(current)-sqrt(historical)))
  
}

perc_change<-function(current,historical){
  
  return(  round( ( ((current-historical)/historical)*100.00
                    ),2) )    
}

eom<-function( month
               ,year
               ,base_day='28'){
  
  return(round_date(as.Date(ISOdate( year=year
                                     ,month=month
                                     ,day=base_day)),'month')-days(1))
}

vio_crimes<-c( 'Aggravated Assault'
                 ,'Forcible rape'
                 ,'Robbery'
                 ,'Murder, non-negligent')

prp_crimes<-c( 'Motor vehicle theft'
              ,'Theft from motor vehicle'
              ,'Theft of motor vehicle parts or accessory'
              ,'Burglary, Breaking and Entering'
              ,'All other larceny')


qol_crimes<-c( 'Weapon law violations'
              ,'Shoplifting')
#Put Total List Together - for single data.table and print table
index_crimes<-c(violent_crimes,c(prp_crimes,qol_crimes))
  
stand_report<-function( data
                       ,crime_list
                       ,pri_yr=2019
                       ,cur_yr=2023
                       ,latest_mon='11'
                       ,title='STANDARD POISSON SCORES'){
    
    
    pri_end_dt<-eom(latest_mon,pri_yr)
    cur_end_dt<-eom(latest_mon,cur_yr)
    
    
    crimes_YTD<-data[NIBRSDescription %in% crime_list]%>%
                               .[ ( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                                    &RMSOccurrenceDate<=as.Date(cur_end_dt))
                                  |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                                     &RMSOccurrenceDate<=as.Date(pri_end_dt)) 
                                  ,.(Freq=sum(OffenseCount))
                                  ,by=c('NIBRSDescription','year')]
    
    
    wide_yr<-dcast( crimes_YTD
                    ,NIBRSDescription~year
                    ,value.var = "Freq")
    
    #wide_yr$`2023`<-wide_yr$`2023`*.952
    
    wide_yr$z_poi<-z_poi(wide_yr$`2023`,wide_yr$`2019`)
    wide_yr$Percent_Change<-perc_change(wide_yr$`2023`,wide_yr$`2019`)
    wide_yr$Difference<-wide_yr$`2023`-wide_yr$`2019`
    
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
    
    return(wide_yr[,.(NIBRSDescription,`2019`,`2023`,Difference,Percent_Change,z_poi,Change,Label)])
}

index_data<-stand_report( multi_year
                         ,index_crimes
                         ,pri_yr=2019
                         ,cur_yr=2023
                         ,latest_mon='11')

index_data[,.(NIBRSDescription,`2019`,`2023`,Difference,Percent_Change)]%>%
  gt(rowname_col = "NIBRSDescription")%>%
  fmt_number( columns=c(`2019`,`2023`,`Difference`)
             ,decimals=0
             ,use_seps=TRUE)%>%
  tab_header( title='Index Crimes Standardized Report - Details'
            ,subtitle=md('**YTD Incidents(Jan-Nov 2019 vs 2023)**'))%>%
  cols_label( NIBRSDescription=md("**Category**")
              ,Percent_Change=md("**% Change**"))%>%
  tab_row_group(label=md("**Societal**"),rows=qol_crimes)%>%
  tab_row_group(label=md("**Property**"),rows=prp_crimes)%>%
  tab_row_group(label=md("**Violent**"),rows=vio_crimes)%>%
  tab_footnote(
    footnote = "** Indicates Change is beyond expected variation",
    locations = cells_column_labels(columns = Percent_Change)
  )%>%
  tab_footnote(
    footnote = "-- Indicates Change is consistent with expected variation",
    locations = cells_column_labels(columns = Percent_Change)
  )

cat_row_nums<-index_data[,.(NIBRSDescription,Label,z_poi)]%>%
                        .[order(z_poi)]%>%
                        .[,id:=seq_len(.N), by = Label]%>%
                        .[,id:=rowid(Label)]
 
cat_cols<-dcast( cat_row_nums
                ,id~Label
                ,value.var="NIBRSDescription")

cat_cols[is.na(cat_cols)]<-' '

cat_cols[,.(UP,DOWN)]%>%gt()%>%
  tab_header( title='Index Crimes Standardized Report'
             ,subtitle=md('**YTD Incidents(Jan-Nov) 2019 vs 2023**'))%>%
  cols_width(everything() ~ px(220))%>%
  tab_options(
    data_row.padding = px(15),
    summary_row.padding = px(15), # A bit more padding for summaries
    row_group.padding = px(15)    # And even more for our groups
  ) %>%
  opt_stylize(style = 6, color = 'gray')


#setDT(baseline)[NIBRSDescription=='Murder, non-negligent',.(Freq=sum(OffenseCount))]
#setDT(year4)[NIBRSDescription=='Murder, non-negligent',.(Freq=sum(OffenseCount))]
#z_poi(280,330)
#perc_change(330,280)
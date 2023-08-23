library('ggrepel')

bas_yr='2019'
pri_yr='2022'
cur_yr='2023'
latest_mon='07'

base_end_dt<-eom(latest_mon,bas_yr)

pri_end_dt<-eom(latest_mon,pri_yr)

cur_end_dt<-eom(latest_mon,cur_yr)

incidents_ytd<-multi_year[ (NIBRSDescription %chin% violent_crimes),]%>%
  .[( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
       &RMSOccurrenceDate<=pri_end_dt)
    |( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
       &RMSOccurrenceDate<=cur_end_dt),]%>%
  .[ (!is.na(MapLongitude))
     |(!is.na(MapLatitude))]%>%
  st_as_sf( coords=c("MapLongitude","MapLatitude")
            ,crs=4326
            ,remove=FALSE)

incidents_ytd_dis<-st_join( incidents_ytd
                           ,districts
                           ,join=st_within)
incidents_ytd_dis<-setDT(incidents_ytd_dis)

#Aggregate
incidents_ytd_agg<-incidents_ytd_dis[,.(OffenseCount=sum(OffenseCount))
                                 ,by=list(DISTRICT,year)]
incidents_ytd_agg<-incidents_ytd_agg[!is.na(DISTRICT)]

#Transpose Column per year
comp_ytds<-dcast( incidents_ytd_agg
                  ,DISTRICT~year
                  ,value.var = c("OffenseCount"))

#Differnces
comp_ytds$diff_prior<-comp_ytds$'2023'-comp_ytds$'2022'
comp_ytds$diff_base<-comp_ytds$'2023'-comp_ytds$'2019'

comp_ytds<-comp_ytds[!is.na(DISTRICT)]

#Join Diff by District
plot_data<-incidents_ytd_agg[comp_ytds,on='DISTRICT']
plot_data$leg_label<-paste(plot_data$DISTRICT,':',plot_data$diff_prior)

##PLOT!!!
ggplot( data=plot_data
       ,aes( x=year
            ,y=OffenseCount
            ,group=leg_label)) +
  geom_line( aes( color=leg_label 
                 #,alpha=1
                 )
            ,line_width=2) +
  geom_point( aes( color=leg_label
                  #,alpha=1
                  )
             ,size=4) +
  #geom_text_repel( data=plot_data[year=='2022']
  #          ,aes(label=leg_label)  
  #          ,hjust=1.35 
  #          ,fontface="bold" 
  #          ,size = 4) +
  geom_text_repel( data=plot_data[year=='2023'] 
            ,aes(label=leg_label) 
            ,hjust=-.35 
            ,fontface="bold" 
            ,size = 4) +
  # move the x axis labels up top
  scale_x_discrete(position="top",expand = c(.01, .01)) +
  theme_bw() +
  # Format tweaks
  # Remove the legend
  theme(legend.position="none") +
  # Remove the panel border
  theme(panel.border=element_blank()) +
  # Remove just about everything from the y axis
  #theme(axis.title.y=element_blank()) +
  #theme(axis.text.y=element_blank()) +
  #theme(panel.grid.major.y=element_blank()) +
  #theme(panel.grid.minor.y=element_blank()) +
  # Remove a few things from the x axis and increase font size
  theme(axis.title.x=element_blank()) +
  #theme(panel.grid.major.x=element_blank()) +
  #theme(axis.text.x.top=element_text(size=12)) +
  # Remove x & y tick marks
  #theme(axis.ticks=element_blank()) +
  # Format title & subtitle
  theme(plot.title=element_text(size=14, face = "bold", hjust = 0.5)) +
  theme(plot.subtitle=element_text(hjust = 0.5)) +
  #  Labeling as desired
  labs(
    title = "Title",
    subtitle = "SUB",
    caption = "Caption"
  )


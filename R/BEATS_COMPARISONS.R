bas_yr='2019'
pri_yr='2022'
cur_yr='2023'
latest_mon='11'

base_end_dt<-eom(latest_mon,bas_yr)
pri_end_dt<-eom(latest_mon,pri_yr)
cur_end_dt<-eom(latest_mon,cur_yr)

## Overall Violent
crimes_filtered<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                            &(RMSOccurrenceDate>='2023-01-01')
                            &(RMSOccurrenceDate<='2023-11-30')]

beats_agg<-crimes_filtered[,.(N=sum(OffenseCount))
                           ,by=c('Beat')]

pre<-setDT(crimes_filtered)

# Recode Premise 
pre[,prem_oth:=ifelse( Premise %in% c( 'Residence, Home (Includes Apartment)'
                                      ,'Parking Lot, Garage'
                                      ,'Highway, Road, Street, Alley'
                                      ,'Bar, Nightclub')
                      ,Premise
                      ,'Other')]

beats_n<-setDT(beats_agg[,c('Beat','N')])              

#NIBRS Premise Recat
beats_prem<-pre[,.(Freq=sum(OffenseCount))
                  ,by=c('prem_oth','Beat')]

beat_fin<-beats_n[ beats_prem
                 ,on=.(Beat)]

beat_fin$prop<-beat_fin$Freq/beat_fin$N

ggplot( data=beat_fin
        ,aes( y=prop
              ,x=prem_oth
              ,group=Beat))+
  geom_bar( position="dodge"
            ,stat="identity")+facet_wrap(~Beat)
 
prem_xtab<-dcast( beat_fin
                  ,Beat~prem_oth
                  ,value.var = c("prop"))
cols
prem_xtab[,(names(prem_xtab)):=lapply(.SD, nafill,fill=0)
    ,.SDcols = cols]

## Overall Houston Recat Premise
prem_ovr<-pre[,.(pop_freq=sum(OffenseCount))
                ,by=c('prem_oth')]

prem_ovr$prop_exp<-prem_ovr$pop_freq/sum(prem_ovr$pop_freq)

ibeat<-'1A40'
#Beat SpecificS
prem_chi_pre<-prem_ovr[ beat_fin[Beat==glue('{ibeat}')]
                       ,on=.(prem_oth)]

exp_tab<-prem_chi_pre[,.(prem_oth,prop=prop_exp,cat='Expected')]
obs_tab<-prem_chi_pre[,.(prem_oth,prop=prop,cat='Observed')]

plot_pre<-rbindlist(list( exp_tab
                         ,obs_tab)) 

ggplot( data=plot_pre
        ,aes( y=prop
              ,x=prem_oth
              ,fill=cat))+
  geom_bar( position="dodge"
            ,stat="identity")+
  ggtitle(glue("Year-To-Date"))+
  theme_economist()+
  scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred'))

## Make sure the chi-squared proportions sum to 1
sum(prem_chi_pre$prop_exp)

chisq.test( prem_chi_pre$Freq
           ,p=prem_chi_pre$prop_exp)

##-Violent
crimes_filtered<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                            &(Beat==glue('{ibeat}'))]%>%
  .[,NIBRSDescription:='Violent']

NIBRS_Trend(indata=crimes_filtered,'Violent')
NIBRS_YTD(indata=crimes_filtered,glue('Beat: {ibeat}\nViolent'))

crime_YTD<-crimes_filtered[ ( RMSOccurrenceDate>=glue('{bas_yr}-01-01')
                             &RMSOccurrenceDate<=base_end_dt)
                           |( RMSOccurrenceDate>=glue('{pri_yr}-01-01')
                             &RMSOccurrenceDate<=pri_end_dt)
                           |( RMSOccurrenceDate>=glue('{cur_yr}-01-01')
                             &RMSOccurrenceDate<=cur_end_dt),]

y2019<-crime_YTD[ (year=='2019')&(Beat==glue('{ibeat}'))
                       ,.(FREQ=sum(OffenseCount)),by=c("Premise")]
y2019$prop<-y2019$FREQ/sum(y2019$FREQ)
y2019$year<-'2019'

y2022<-crime_YTD[ (year=='2022')&(Beat==glue('{ibeat}'))
                        ,.(FREQ=sum(OffenseCount)),by=c("Premise")]
y2022$prop<-y2022$FREQ/sum(y2022$FREQ)
y2022$year<-'2022'

y2023<-crime_YTD[ (year=='2023')&(Beat==glue('{ibeat}'))
                        ,.(FREQ=sum(OffenseCount)),by=c("Premise")]
y2023$prop<-y2023$FREQ/sum(y2023$FREQ)
y2023$year<-'2023'

data_concat<-rbindlist(list(y2019,y2022,y2023))

ggplot( data=data_concat
        ,aes( y=FREQ
              ,x=Premise
              ,fill=year))+
  geom_bar( position="dodge"
            ,stat="identity")+
  coord_flip()+
  ggtitle(glue("Beat {ibeat}\n Jan-Jun Violent Crime Incidents"))+
  theme_economist()+
  scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred'))

#Data Wide
data_wide<-dcast( data_concat
                  ,Premise~year
                  ,value.var=c( 'FREQ'
                                ,"prop"))
col_list<-c('FREQ_2019','FREQ_2022','FREQ_2023')
data_wide[,(col_list):=lapply(.SD, nafill,fill=0)
          ,.SDcols = col_list]
 
data_wide$diff_22<-data_wide$FREQ_2023-data_wide$FREQ_2022

ggplot( data=data_wide
        ,aes( y=diff_22
              ,x=Premise
              ))+
  geom_bar( position="dodge"
            ,stat="identity")+
  coord_flip()+
  ggtitle(glue("Beat {ibeat}\n Changes 2022-2023\n Violent Crime Incidents"))+
  theme_economist()+
  scale_fill_manual(values=c('darkblue', 'darkgreen', 'darkred'))

## 18F30 Drill Down Premises
drill_down<-multi_year[ (NIBRSDescription %chin% violent_crimes)
                            &(Beat==glue('{ibeat}'))
                            &(Premise=='Parking Lot, Garage')#&(Premise=='Bar, Nightclub')
                            &(year=='2023')]

dd_agg<-drill_down[,.(FREQ=sum(OffenseCount))
                     ,by=c( 'StreetNo'
                           ,'StreetName'
                           ,'StreetType')]

  
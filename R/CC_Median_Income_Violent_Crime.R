## Median income data by COH Council Districts was harvested from 
#    https://www.houstontx.gov/planning/Demographics/ '2024 Council District Profiles (2021 Demographics). 
# A - 62042
# B - 36087
# C - 114144
# D - 56141
# E - 91888
# F - 49313
# G - 94917
# H - 54879
# I - 49925
# J - 37155
# K - 60130

## Cohen J. (1988). Statistical Power Analysis for the Behavioral Sciences. New York, NY: Routledge Academic [Google Scholar] """

medians<-list( A=62042
              ,B=36087
              ,C=114144
              ,D=56141
              ,E=91888
              ,F=49313
              ,G=94917
              ,H=54879
              ,I=49925
              ,J=37155
              ,K=60130)

medians<-data.table(names = names(medians), medians)

#####

# Violent Crime Totals by district
violents_2021<-multi_year[  (NIBRSDescription %chin% violent_crimes)
                           &(year==2022) 
                         ]%>%
                         .[ (!is.na(MapLongitude))
                          |(!is.na(MapLatitude))] %>%
                         st_as_sf( coords=c("MapLongitude","MapLatitude")
                                  ,crs=4326
                                  ,remove=FALSE)

violent_dist<-st_join( violents_2021
                      ,districts
                      ,join=st_within)

#Aggregate
agg<-setDT(violent_dist)[,.(OffenseCount=sum(OffenseCount))
                         ,by=c('DISTRICT','year')]%>%.[!is.na(DISTRICT)]


agg<-medians[agg,on=c(names='DISTRICT')]

print(agg[order(names)])

# Hypothedsis Test
cor.test( x=as.numeric(agg$medians)
                 ,y=as.numeric(agg$OffenseCount)
                 ,method = 'spearman')

"Median income data by COH Council Districts was harvested from https://www.houstontx.gov/planning/Demographics/ '2024 Council District Profiles (2021 Demographics)'. 

Using Speamans' Rank Correlation test, median incomes were negatively correlated to Violent Crime Incident Counts in both 2022(pvalue=0.01) and 2023(pvalue=0.02). Correlations according to Cohen* were both 'large' - 2022: -0.77 and 2023: -0.68.

*Cohen J. (1988). Statistical Power Analysis for the Behavioral Sciences. New York, NY: Routledge Academic [Google Scholar] "

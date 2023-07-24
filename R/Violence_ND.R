
## Overall Violent
crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
  .[,NIBRSDescription:='Violent']

NIBRS_Trend(indata=crimes_filtered,'Violent')
NIBRS_YTD(indata=crimes_filtered,'Violent')

## Individual Crimes
for (icrime in violent_crimes) {
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  print(nrow(crimes_filtered) )
  
  print(NIBRS_Trend(indata=crimes_filtered,icrime))
  print(NIBRS_YTD(indata=crimes_filtered,icrime))
}

#Current Month Location Plots

#YTD Districts
##Slope Plot
#YTD Beats
##Over all net calculations
##Chloropleth

auto_crimes<-c( 'Motor vehicle theft'
               ,'Theft from motor vehicle'
               ,'Theft of motor vehicle parts or accessory'
              )

## Individual Crimes
for (icrime in auto_crimes) {
  print(icrime)
  crimes_filtered<-multi_year[NIBRSDescription==icrime]
  print(nrow(crimes_filtered) )
  
  print(NIBRS_Trend(indata=crimes_filtered,icrime))
  print(NIBRS_YTD(indata=crimes_filtered,icrime))
}

## Did they CC ring get busted in Aug 2022?

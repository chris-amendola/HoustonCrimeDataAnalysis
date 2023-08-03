crimes_filtered<-multi_year[NIBRSDescription=='Burglary, Breaking and Entering']
  
NIBRS_Trend(indata=crimes_filtered,'Burglary, Breaking and Entering')
NIBRS_YTD(indata=crimes_filtered,'Burglary, Breaking and Entering')

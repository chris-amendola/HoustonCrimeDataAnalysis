crimes_filtered<-multi_year[NIBRSDescription=='Shoplifting']

NIBRS_Trend(indata=crimes_filtered,'Shoplifting')
NIBRS_YTD(indata=crimes_filtered,'Shoplifting')
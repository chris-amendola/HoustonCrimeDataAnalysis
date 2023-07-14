# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 18:13:44 2023

@author: chris
"""
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)

#datetime.now() - pd.DateOffset(months=5)).strftime("%m/%d/%Y")
df=multi_year.loc[ (multi_year['RMSOccurrenceDate']>='01/01/2023')
                  &(multi_year['StreetName']=='WESTHEIMER')
                   &(multi_year['StreetNo']>='6260')
                   &(multi_year['StreetNo']<'6268')]

properties = { "border":"2px solid gray"
              ,"color":"blue"
              ,"font-size": "16px"}

show=df[['RMSOccurrenceDate','NIBRSDescription','OffenseCount','StreetNo']]\
     .rename(columns={ 'RMSOccurrenceDate':'OccurrenceDate'
                      ,'NIBRSDescription':'Description'})\
     .sort_values('OccurrenceDate')\
     .reset_index(drop=True)\
     .style.set_properties(**properties)\
     .hide_index()
  
show.to_html('C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/scratch/table.html'
             )
# -*- coding: utf-8 -*-
"""
Created on Wed May 17 08:52:46 2023

@author: chris
"""
## Data Sourced -> https://txucr.nibrs.com/SRSReport/CrimeTrends

import pandas as pd
import matplotlib.pyplot as plt
import calendar


monname2num={month: str(index).zfill(2) for index, month in enumerate(calendar.month_name) if month}

data=pd.read_excel(open( 'C:/Users/chris/Downloads/SRS Offense Trends - Offense_TrendsReport for Jan - 2018 to May - 2023.xlsx'
                            ,'rb')
                      ,sheet_name='Sheet1')

data['mon_num']=data.Month.map(monname2num)
data['Year_Mon']=data['Year'].map(str)+'-'+data['mon_num'].map(str) 

def trendx( _inbound
           ,_category
           ,_range):
    
    _data=_inbound.loc[ _inbound['Description']==_category
                     ,['Year_Mon','SRS Offense Count']]
    
    _data.sort_values('Year_Mon',ascending=True,inplace=True)
    
    _data[f'''Rolling_{_range}_Month''']=_data['SRS Offense Count'].rolling(_range).mean()

    _data.loc[ :,['Year_Mon',f'''Rolling_{_range}_Month''']]\
         .plot( x='Year_Mon'
               ,title=f'''{_category}''')

    return _data

for catx in data['Description'].drop_duplicates():
    trendx(data,catx,12)


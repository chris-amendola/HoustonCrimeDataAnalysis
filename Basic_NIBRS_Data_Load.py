# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 11:46:27 2023

@author: chris
"""
# -*- coding: utf-8 -*-
"""
Created on Mon May 29 17:36:34 2023

@author: chris
"""
## https://www.houstontx.gov/police/cs/Monthly_Crime_Data_by_Street_and_Police_Beat.htm

import pandas as pd
import numpy as np
import scipy.stats
from datetime import datetime
from datetime import date
import sqlite3

print(datetime.now())
print((datetime.now() - pd.DateOffset(months=3)).strftime("%m/%d/%Y"))

## Basic Graphing/Plotting Package
import matplotlib
import matplotlib.pyplot as plt
matplotlib.style.use('bmh')

## Deep learning
import minisom
from sklearn import preprocessing, cluster
import scipy

## Geo Spatial Plotting
import geopandas as gpd
import geodatasets
import folium
import re
import branca.colormap as cm

#Set some parameters
where_the_data_is='C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/HPD_NIBRS/'

bydim='Overall'
group_dims=['NIBRSDescription',bydim]
crimes=[ 'Aggravated Assault'
        ,'Robbery'
        ,'Forcible rape'
        ,'Murder, non-negligent'
        ,'Motor vehicle theft'
        ,'Destruction, damage, vandalism'
        ,'Weapon law violations'
        ,'Burglary, Breaking and Entering'
        ,'Theft from motor vehicle'
        ,'Theft of motor vehicle parts or accessory'
        ,'Trespass of real property'
        ,'Shoplifting'
        ]

all_colors=[ 'red'
            ,'gray'
            ,'blue'
            ,'green'
            ,'purple'
            ,'orange'
            ,'pink'
            ,'yellow'
            ,'olive'
            ,'magenta'
            ,'chocolate'
            ,'brown'
            ,'aqua'
            ,'violet'
            ,'wheat'
            ,'darkornage']


# Reuseable function                    
def nibrs_trendx( _inbound
                 ,_category
                 ,_range
                 ,_subtitle=''):
    
    _data=_inbound.loc[ (_inbound['NIBRSDescription']==_category)
                     ,['year_mon','OffenseCount']]\
                  .groupby('year_mon')\
                  .agg({'OffenseCount':'sum'})\
                  .reset_index()    
    
    _data.sort_values('year_mon',ascending=True,inplace=True)
    
    _data[f'''Rolling_{_range}_Month''']=_data['OffenseCount'].rolling(_range).mean()

    _data=_data.loc[_data['year_mon']>'2019-12-01',['year_mon',f'''Rolling_{_range}_Month''']]
    
    _min=_data[f'''Rolling_{_range}_Month'''].min()
    _max=_data[f'''Rolling_{_range}_Month'''].max()
    _start=_data.loc[_data['year_mon']==_data['year_mon'].min()][f'''Rolling_{_range}_Month'''].min()
    _finish=_data.loc[_data['year_mon']==_data['year_mon'].max()][f'''Rolling_{_range}_Month'''].min()
    
    _data.plot( x='year_mon'
               ,title=f'''{_category} {_subtitle}'''
               ,figsize=(12,6))
    #.legend(bbox_to_anchor=(1.0, 1.0))

    plt.axhline(y=_start
                ,color='green'
                ,linewidth=1
                ,linestyle='--'
                ,)
    
    plt.axhline(y=_finish
                ,color='blue'
                ,linewidth=1
                ,linestyle='--')
    
    plt.axhline(y=_max
                ,color='red'
                ,linewidth=1
                ,linestyle='--')
    
    # plt.annotate('Data Sourced from:https://www.houstontx.gov/police/cs/Monthly_Crime_Data_by_Street_and_Police_Beat.htm',
    #             xy = (1.3, -0.25),
    #             xycoords='axes fraction',
    #             ha='right',
    #             va="center",
    #             fontsize=10)
    
    return _data


def p50(x):
    return x.quantile(0.50)

def p25(x):
    return x.quantile(0.25)

def p75(x):
    return x.quantile(0.75)

def p90(x):
    return x.quantile(0.90)

def YTD( _inbound
        ,_category
        ,_subtitle=''):
    
    _data=_inbound.loc[ (_inbound['NIBRSDescription']==_category)
                       ,] 

    ## YEAR TO DATE
    # Filter and Aggregate
    bas_agg=_data.loc[ (_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2019-04-30')
                           &(_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2019-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    pri_agg=_data.loc[ (_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-04-30')
                           &(_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    cur_agg=_data.loc[ (_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-04-30')
                           &(_data['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    comp_ytds=bas_agg.join( pri_agg
                            ,on=group_dims
                            ,lsuffix='_2019'
                            ,rsuffix='_2022')\
                      .join( cur_agg 
                            ,on=group_dims)\
                       .reset_index()      

    comp_ytds['diff_2022']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_2022']
    comp_ytds['diff_2019']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_2019']

    comp_ytds['perc_2022']=comp_ytds['diff_2022']/comp_ytds['OffenseCount_2022']
    comp_ytds['perc_2019']=comp_ytds['diff_2019']/comp_ytds['OffenseCount_2019']

    comp_ytds.fillna(0,inplace=True)

    comp_ytds\
                 .set_index(group_dims).loc[:,['OffenseCount_2019','OffenseCount_2022','OffenseCount']]\
                 .plot( kind='bar'
                      ,figsize=(12,6)
                      ,fontsize=16
                      ,rot=0
                      ,title=f'''Year-To-Date Violent, 2019,2022,2023\n{_subtitle}'''
                      )          
    return comp_ytds

# Import Data
sql_con = sqlite3.connect("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/incoming_data.sqlite")
 
multi_year=pd.read_sql_query('''select * from all_years_incoming''', sql_con)
multi_year['RMSOccurrenceDate']=pd.to_datetime(multi_year['RMSOccurrenceDate'])
multi_year['year_mon']=multi_year['year_mon'].astype("datetime64[M]")
multi_year.info()


all_cats=pd.read_sql_query('''select * from categories''', sql_con)
all_zips=pd.read_sql_query('''select * from zips''', sql_con)     
all_premise=pd.read_sql_query('''select * from premises''', sql_con)

sql_con.close()

# nibrs_trendx( multi_year
#              ,''
#              ,12
#              ,_subtitle='\nOverall')

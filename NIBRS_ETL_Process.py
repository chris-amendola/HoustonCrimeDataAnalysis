# -*- coding: utf-8 -*-
"""
Created on Wed May 31 13:58:37 2023

@author: chris
"""
import pandas as pd

from datetime import datetime
from datetime import date

#Set some parameters
where_the_data_is='C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/HPD_NIBRS/'

print(datetime.now())
print((datetime.now() - pd.DateOffset(years=1)).strftime("%m/%d/%Y"))

# Import Data - Excel
#2019
baseline=pd.read_excel( open( f'''{where_the_data_is}2019_NIBRSPublicView.Jan1-Dec31.xlsx'''
                            , 'rb')
                        ,sheet_name='2019 Year End - Analysis')

# Column Renames
baseline=baseline.loc[baseline['Occurrence\nDate'].dt.strftime('%Y-%m-%d')>'2018-12-31']\
                 .rename(columns={ 'Offense\nCount':'OffenseCount'
                                  ,'Occurrence\nDate':'RMSOccurrenceDate'
                                  ,'ZIP Code':'ZIPCode'})
# Synthetic Variables
baseline["year_mon"]=baseline['RMSOccurrenceDate'].astype("datetime64[M]")
baseline['StreetType']=baseline['Street\nType']
baseline['StreetNo']=baseline['Block Range']
baseline['Overall']='OverAll'

print('Baseline')
print(baseline["year_mon"].min(),baseline["year_mon"].max())

#2020
year1=pd.read_excel( open( f'''{where_the_data_is}NIBRSPublicView.Jan1-Dec31-2020.xlsx'''
                            , 'rb')
                        ,sheet_name='Oct 2020 NIBRS Detailed-Origina')

# Column renames
year1=year1.rename(columns={ 'Offense\nCount':'OffenseCount'
                            ,'Occurrence\nDate':'RMSOccurrenceDate'
                            ,'ZIP Code':'ZIPCode'})

year1["year_mon"]=year1['RMSOccurrenceDate'].astype("datetime64[M]")
year1['Overall']='OverAll'
year1['StreetType']=year1['Street\nType']
year1['StreetNo']=year1['Block Range']

print('Year1(2020)')
print(year1["year_mon"].max())

#2021
year2=pd.read_excel( open( f'''{where_the_data_is}NIBRSPublicViewDec21.xlsx'''
                            , 'rb')
                        ,sheet_name='NIBRSPublicReportByClassByOccur')

# Date rounding to month
year2["year_mon"]=year2["RMSOccurrenceDate"].astype("datetime64[M]")
year2['Overall']='OverAll'

print('Year2(2020)')
print(year2["year_mon"].max())

#2022
year3=pd.read_excel( open( f'''{where_the_data_is}NIBRSPublicViewDec22.xlsx'''
                            , 'rb')
                        ,sheet_name='NIBRSPublicReportByClassByOccur')

# Date rounding to month
year3["year_mon"]=year3["RMSOccurrenceDate"].astype("datetime64[M]")
year3['Overall']='OverAll'

print('Year3(2022)')
print(year3["year_mon"].max())

#2023
year4=pd.read_excel(open( 'C:/Users/chris/Downloads/NIBRSPublicViewMay23.xlsx'
                            ,'rb')
                      ,sheet_name='NIBRSPublicReportByClassByOccur')  

# Date rounding to month
year4["year_mon"]=year4['RMSOccurrenceDate'].astype("datetime64[M]")
year4['Overall']='OverAll'

print('Year4(2023)')
print(year4["year_mon"].max())

multi_year=pd.concat([ year4
                      ,year3
                      ,year2
                      ,year1
                      ,baseline])
multi_year['year']=multi_year['RMSOccurrenceDate'].dt.year.astype('Int64')
multi_year['ZIPCode']=multi_year['ZIPCode'].astype(str).str.slice(0,5)

multi_year.info()

all_cats=multi_year['NIBRSDescription'].drop_duplicates()
all_zips=multi_year['ZIPCode'].drop_duplicates()      
all_premise=multi_year['Premise'].drop_duplicates() 

import pyodbc
import sqlite3
sql_con = sqlite3.connect("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/incoming_data.sqlite")

multi_year.to_sql( "all_years_incoming"
                  ,sql_con
                  ,if_exists="replace")

all_cats.to_sql( "categories"
                  ,sql_con
                  ,if_exists="replace")
all_zips.to_sql( "zips"
                  ,sql_con
                  ,if_exists="replace")
all_premise.to_sql( "premises"
                  ,sql_con
                  ,if_exists="replace")

sql_con.close()






 
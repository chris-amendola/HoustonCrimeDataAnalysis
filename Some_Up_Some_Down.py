# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 11:49:56 2023

@author: chris
"""
violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape'
                ,'Robbery'
                ,'Murder, non-negligent']

_category='Violent Crime Incident Reports'
_subtitle=violent_crimes 
_range=12

_inbound=multi_year.loc[ multi_year['NIBRSDescription'].isin(violent_crimes)
                       ,['year_mon','OffenseCount']]        

_data=_inbound.groupby('year_mon')\
              .agg({'OffenseCount':'sum'})\
              .reset_index()    

_data.sort_values('year_mon',ascending=True,inplace=True)

_data[f'''Rolling_{_range}_Month''']=_data['OffenseCount'].rolling(_range).mean()

_data=_data.loc[_data['year_mon']>'2019-12-01',['year_mon',f'''Rolling_{_range}_Month''']]

_data.plot( x='year_mon'
           ,title=f'''{_category}\n{_subtitle}''')

plt.annotate('Data Sourced from:https://www.houstontx.gov/police/cs/Monthly_Crime_Data_by_Street_and_Police_Beat.htm',
            xy = (1.3, -0.25),
            xycoords='axes fraction',
            ha='right',
            va="center",
            fontsize=10)

property_crimes=[ 'Motor vehicle theft'
                 ,'Burglary, Breaking and Entering'
                 ,'All other larceny'
                 ,'Theft from motor vehicle'
                 ,'Theft of motor vehicle parts or accessory'
                 ,'Arson'
                 ,'Theft from building'
                 ,'Stolen property offenses']

_category='Property Incident Reports'
_subtitle=property_crimes 
_range=12

_inbound=multi_year.loc[ multi_year['NIBRSDescription'].isin(property_crimes)
                       ,['year_mon','OffenseCount']]        

_data=_inbound.groupby('year_mon')\
              .agg({'OffenseCount':'sum'})\
              .reset_index()    

_data.sort_values('year_mon',ascending=True,inplace=True)

_data[f'''Rolling_{_range}_Month''']=_data['OffenseCount'].rolling(_range).mean()

_data=_data.loc[_data['year_mon']>'2019-12-01',['year_mon',f'''Rolling_{_range}_Month''']]

_data.plot( x='year_mon'
           ,title=f'''{_category}\n{_subtitle}''')

plt.annotate('Data Sourced from:https://www.houstontx.gov/police/cs/Monthly_Crime_Data_by_Street_and_Police_Beat.htm',
            xy = (1.3, -0.25),
            xycoords='axes fraction',
            ha='right',
            va="center",
            fontsize=10)
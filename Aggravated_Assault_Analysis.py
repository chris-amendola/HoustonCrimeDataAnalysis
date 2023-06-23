# -*- coding: utf-8 -*-
"""
Created on Sun Jun  4 11:58:09 2023

@author: chris
"""
# My Stuff
violent_crimes=['Aggravated Assault']

_category='12-Month Rolling Average of Incident Reports for:'
_subtitle=violent_crimes 
_range=12

_inbound=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes)) 
                       ,['year_mon','OffenseCount']]        

_data=_inbound.groupby('year_mon')\
              .agg({'OffenseCount':'sum'})\
              .reset_index()    

_data.sort_values('year_mon',ascending=True,inplace=True)

_data[f'''Rolling_{_range}_Month''']=_data['OffenseCount'].rolling(_range).mean()

_data=_data.loc[_data['year_mon']>'2019-12-01',['year_mon',f'''Rolling_{_range}_Month''']]

print( _category
      ,'\n','--Min: ',_data[f'''Rolling_{_range}_Month'''].min()
      ,'\n','--Max: ',_data[f'''Rolling_{_range}_Month'''].max()
      ,'\n','--Start: ',_data.loc[_data['year_mon']==_data['year_mon'].min()][f'''Rolling_{_range}_Month'''].min()
      ,'\n','--Finish: ',_data.loc[_data['year_mon']==_data['year_mon'].max()][f'''Rolling_{_range}_Month'''].min()
      ,'\n')

_data.plot( x='year_mon'
           ,ylim=(0,2000)
           ,title=f'''{_category}\n{_subtitle}''')

# plt.annotate('Data Sourced from:https://www.houstontx.gov/police/cs/Monthly_Crime_Data_by_Street_and_Police_Beat.htm',
#             xy = (1.3, -0.25),
#             xycoords='axes fraction',
#             ha='right',
#             va="center",
#             fontsize=10)

# https://theglendagordyresearchcenter.com/wp-content/uploads/Monthly_Crime_IndexDec2022FINAL.pdf

# Aggravated  Assaults
year=['2022','2021','2020','2019']
incidents=[97350,101433,99665,64536]
filings=[4614,5083,4505,3078]

import pandas as pd
   
raw={ 'year':year
     ,'Incidents':incidents
     ,'Filings':filings} 
    
data=pd.DataFrame(raw).sort_values('year')
data['ratio']=data['Filings']/data['Incidents']

piv_data=data.pivot_table( columns='year'
                 ,values=['Incidents','Filings']
             )
piv_data['d1920']=piv_data['2020']-piv_data['2019']
piv_data['d2021']=piv_data['2021']-piv_data['2020']
piv_data['d2122']=piv_data['2022']-piv_data['2021']
piv_data['y19_y20']=(piv_data['d1920']/piv_data['2019'])*100.00
piv_data['y20_y21']=(piv_data['d2021']/piv_data['2020'])*100.00
piv_data['y21_y22']=(piv_data['d2122']/piv_data['2021'])*100.00

## Counts
_category='Aggravated  Assault 2019-2022'
_subtitle='Incident Report Counts' 
data.plot( kind='bar'
          ,x='year'
          ,y=['Incidents']
          ,title=f'''{_category}\n{_subtitle}''')

# plt.annotate('Raw Data Sourced from:https://theglendagordyresearchcenter.com/wp-content/uploads/Monthly_Crime_IndexDec2022FINAL.pdf',
#              xy = (1.3, -0.25),
#              xycoords='axes fraction',
#              ha='right',
#              va="center",
#             fontsize=10)

_category='Aggravated  Assault 2019-2022'
_subtitle='Case Filing Counts' 
data.plot( kind='bar'
          ,x='year'
          ,y=['Filings']
          ,title=f'''{_category}\n{_subtitle}''')

# plt.annotate('Raw Data Sourced from:https://theglendagordyresearchcenter.com/wp-content/uploads/Monthly_Crime_IndexDec2022FINAL.pdf',
#              xy = (1.3, -0.25),
#              xycoords='axes fraction',
#              ha='right',
#              va="center",
#             fontsize=10)

# Ratio
_category='Aggravated  Assault 2019-2022'
_subtitle='Ratio of Incident Report Counts to Case Filing Counts' 
data.plot( kind='bar'
          ,x='year'
          ,y='ratio'
          ,ylim=(0,.1)
          ,title=f'''{_category}\n{_subtitle})''')
# plt.annotate('Raw Data Sourced from:https://theglendagordyresearchcenter.com/wp-content/uploads/Monthly_Crime_IndexDec2022FINAL.pdf',
#              xy = (1.3, -0.25),
#              xycoords='axes fraction',
#              ha='right',
#              va="center",
#             fontsize=10)

# https://theglendagordyresearchcenter.com/aggravated-assault/
# Set some parameters
where_the_data_is='C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Data/'

filing_data_gg=pd.read_csv(f'''{where_the_data_is}Aggravated Assault Filings Trends Overview_data.csv''')

deadly=filing_data_gg.loc[filing_data_gg['literal']=='AGG ASSAULT W/DEADLY WEAPON']

dead_piv=deadly.pivot_table( columns='Year of Filing Date'
                             ,values=['Count of Id'])
dead_piv['d1920']=dead_piv[2020]-dead_piv[2019]
dead_piv['d2021']=dead_piv[2021]-dead_piv[2020]
dead_piv['d2122']=dead_piv[2022]-dead_piv[2021]
dead_piv['y19_y20']=(dead_piv['d1920']/dead_piv[2019])*100.00
dead_piv['y20_y21']=(dead_piv['d2021']/dead_piv[2020])*100.00
dead_piv['y21_y22']=(dead_piv['d2122']/dead_piv[2021])*100.00

dead_piv.reset_index(inplace=True)
dead_piv['index']='Agg_Aslt_Dead'
dead_piv.set_index('index',inplace=True)

ctab=pd.pivot_table( filing_data_gg.loc[filing_data_gg['Year of Filing Date']>2018]
                    ,values='Count of Id'
                    ,columns=['literal']
                    ,index=['Year of Filing Date'])

ctab.plot(kind='line')
plt.legend(loc='upper right',bbox_to_anchor=(1.75,1))
# plt.annotate('Raw Data Sourced from:https://theglendagordyresearchcenter.com/aggravated-assault/',
#              xy = (1.3, -0.25),
#              xycoords='axes fraction',
#              ha='right',
#              va="center",
#             fontsize=10)

# Changes as a percent of previous year for incident counts and case filings - Aggrivated Assault
cool=pd.concat([piv_data[['y19_y20','y20_y21','y21_y22']],dead_piv[['y19_y20','y20_y21','y21_y22']]])

cool\
    .sort_index(ascending=False)\
    .plot(kind='bar'
          ,title='Percent Change from Prior Year, 2019-2022\nAggravated  Assault'
          ,rot=0
          ,figsize=(12,6))
    
plt.legend(loc='upper right',bbox_to_anchor=(1,1))
# plt.annotate('Raw Data Sourced from:https://theglendagordyresearchcenter.com/aggravated-assault/',
#              xy = (1.25, -0.25),
#              xycoords='axes fraction',
#              ha='right',
#              va="center",
#             fontsize=10)
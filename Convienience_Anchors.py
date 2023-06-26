# -*- coding: utf-8 -*-
"""
Created on Wed Jun 21 09:21:32 2023

@author: chris
"""
## EDA Address and Premise
eda=multi_year[[ 'StreetName'
                ,'StreetNo'
                ,'StreetType'
                ,'Suffix'
                ,'Premise'
                ,'OffenseCount'
                ,'year'
                ,'year_mon']]

eda[['StreetName','StreetNo','StreetType','Suffix']]=eda[['StreetName','StreetNo','StreetType','Suffix']]\
                                                                .fillna('_')

eda_rev1=eda.groupby(['StreetName','StreetNo','StreetType','Suffix','Premise'])\
.agg({'OffenseCount':'count'}).reset_index()

# Look at possible Association Rules for Premises at locations 


##
# Find Locations that are identified as Service Stations for at least 5 incidents
# in 2022

prem_sum=multi_year.loc[ multi_year['year']==2022
                        ,['StreetName','StreetNo','StreetType','Suffix','Premise','OffenseCount','year']]\
                   .fillna('_')\
                   .groupby(['StreetName','StreetNo','StreetType','Suffix','Premise'])\
                   .agg({'OffenseCount':'count'}).reset_index()
        
conv=prem_sum.loc[ (prem_sum['Premise']=='Service, Gas Station')
                  &(prem_sum['OffenseCount']>4)]        

conv[['StreetName','StreetNo','StreetType','Suffix']]=conv[['StreetName','StreetNo','StreetType','Suffix']]\
                                                                .fillna('_')
prem_sum[['StreetName','StreetNo','StreetType','Suffix']]=prem_sum[['StreetName','StreetNo','StreetType','Suffix']]\
                                                                .fillna('_')

# Find all incidents +/- 3 months of 2022 for the addresses found above
alt_prem_addr=multi_year.loc[ (multi_year['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2021-10-1')
                                         &(multi_year['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-03-31')]\
                         .merge( conv
                               ,on=['StreetName','StreetNo','StreetType','Suffix']
                               ,how='inner'
                               ,suffixes=('_ind','_con'))

alt_prem_addr['loc_key']=alt_prem_addr[['StreetName','StreetNo','StreetType','Suffix']]\
                             .agg('|'.join, axis=1) 

####
prem_desc_xtab=alt_prem_addr.groupby(['Premise_ind','NIBRSDescription'])\
                    .agg({'OffenseCount_ind':'count'})
                    
prem_uni=alt_prem_addr.groupby(['Premise_ind'])\
                    .agg({'OffenseCount_ind':'count'})
                    
desc_uni=alt_prem_addr.groupby(['NIBRSDescription'])\
                    .agg({'OffenseCount_ind':'count'})
                                        

ordered=alt_prem_addr.sort_values(['loc_key','RMSOccurrenceDate']).head(200)
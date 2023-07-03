# -*- coding: utf-8 -*-
"""
Created on Sun Jul  2 08:33:28 2023

@author: chris
"""
violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape' 
                ,'Robbery'
                ,'Murder, non-negligent']

start='01'
end='06'

bydim='Overall'
group_dims=['NIBRSDescription',bydim]

from shapely.geometry import shape, GeometryCollection, Point
import geopandas as gpd

matplotlib.style.use('ggplot')

districts=gpd.read_file('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson')

pre_df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                      &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2022''')
                      &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                      ,[ 'ZIPCode'
                        ,'year'
                        ,'year_mon'
                        ,'RMSOccurrenceDate'
                        ,'Premise'
                        ,'NIBRSDescription'
                        ,'OffenseCount'
                        ,'StreetNo'
                        ,'StreetName'
                        ,'MapLatitude'
                        ,'MapLongitude'
                        ,'Overall']]

pre_df['coords']=list(zip(pre_df['MapLongitude'],pre_df['MapLatitude']))
pre_df['coords']=pre_df['coords'].apply(Point)

df_join=gpd.GeoDataFrame( pre_df
                         ,geometry='coords'
                         ,crs=districts.crs)

df=gpd.tools.sjoin( df_join
                   ,districts
                   ,predicate="within"
                   ,how='left')

## Agg by offense type
group_dims=['NIBRSDescription','DISTRICT','year']
off_agg=df.loc[  ((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01'))
               |((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01'))]\
          .groupby(group_dims)\
          .agg({'OffenseCount':'sum'}).reset_index()

## Agg to overall
group_dims=['DISTRICT','year']
ovr_agg=df.loc[  ((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01'))
               |((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01'))]\
          .groupby(group_dims)\
          .agg({'OffenseCount':'sum'}).reset_index()
          
ovr_piv=ovr_agg.pivot( index='DISTRICT'
                      ,columns='year'
                      ,values='OffenseCount')
ovr_piv['diff']=ovr_piv[2023]-ovr_piv[2022]

## District Slope plot
fig, ax = plt.subplots(1, figsize=(10,10),facecolor='darkgrey')
for i in district_list:
    temp = ovr_agg[ovr_agg['DISTRICT']==i]
    i_diff=ovr_piv.loc[ovr_piv.index==i,'diff'].values[0]
    plt.plot(temp.year, temp.OffenseCount,marker='o',markersize=5)
    #plt.text(temp.year.values[0]+0.02, temp.OffenseCount.values[0]+0.02, i)
    # start label
    plt.text( temp.year.values[1]+0.14
             ,temp.OffenseCount.values[1]
             ,f'''{i} ({i_diff})''', ha='right')
    
plt.xlim(2022.5,2023.5)
plt.xticks([2022, 2023])
plt.ylabel('Incidents')

# grid
ax.xaxis.grid( color='black'
              ,linestyle='solid'
              ,which='both'
              ,alpha=0.9)
ax.yaxis.grid( color='black'
              ,linestyle='dashed'
              ,which='both'
              ,alpha=0.1)
# remove spines
ax.spines['right'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['top'].set_visible(False)

plt.title( 'Houston Council Districts\nYTD 2022 to 2023\nViolent Crime Counts(Change)'
          ,loc='left'
          ,fontsize=20)

plt.legend( district_list
           ,loc='upper right'
           ,frameon=False)
plt.show()

## G is soooo special
group_dims=['DISTRICT','year_mon','year']

G=df.loc[  (((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01'))
               |((df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-05-31')
                &(df['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01')))
               &(df['DISTRICT']=='G')]\
          .groupby(group_dims)\
          .agg({'OffenseCount':'sum'}).reset_index()
          
G['Month']=pd.to_datetime(G['year_mon']).dt.strftime('%m')  

G.pivot( index='Month'
        ,columns='year'
        ,values='OffenseCount')\
 .plot( kind='bar'
       ,stacked=False
       ,title='Houston Council District G')


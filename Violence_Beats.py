# -*- coding: utf-8 -*-
"""
Created on Fri Jun 16 09:43:36 2023

@author: chris
"""
geofile='COH_POLICE_BEATS.geojson'
beat_gis=gpd.read_file(f'''C:/Users/chris/Downloads/{geofile}''')
beat_gis.info()

gis_beats=beat_gis['Beats'].dropna().drop_duplicates()

## There are non-patrol,non-HPD "beats" reported in the data
## This list is longer than list from GIS data
actual_beats=multi_year['Beat'].dropna().drop_duplicates()

violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape'
                ,'Robbery'
                ,'Murder, non-negligent']

d={'OffenseCount': [0],'NIBRSDescription':'Violent','Overall':'OverAll'}
hold_df=pd.DataFrame(data=d).set_index(['NIBRSDescription','Overall'])

def beat_analysis(beati):
    print('-',beati,'-')
    trend=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                         &( (multi_year['Beat'].str.contains(beati,na=False))
                           )]
    trend['NIBRSDescription']='Violent'
    print(len(trend.index))
    if len(trend.index)!=0:
    
        ## YEAR TO DATE
        # Filter and Aggregate
        bas_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2019-05-31')
                               &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2019-01-01')]\
                .groupby(group_dims)\
                .agg({'OffenseCount':'sum'})
        print(len(bas_agg.index))        
        if len(bas_agg.index)==0:
            bas_agg=hold_df
                
        pri_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-05-31')
                               &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01')]\
                .groupby(group_dims)\
                .agg({'OffenseCount':'sum'})
        print(len(pri_agg.index))
        if len(pri_agg.index)==0:
            pri_agg=hold_df
    
        cur_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-05-31')
                               &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01')]\
                .groupby(group_dims)\
                .agg({'OffenseCount':'sum'})
        print(len(cur_agg.index))  
        if len(cur_agg.index)==0:
            cur_agg=hold_df
    
        comp_ytds=bas_agg.join( pri_agg
                                ,on=group_dims
                                ,lsuffix='_Base'
                                ,rsuffix='_Prior')\
                          .join( cur_agg 
                                ,on=group_dims)\
                           .reset_index()      
    
        comp_ytds['diff_prior']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_Prior']
        comp_ytds['diff_base']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_Base']
    
        comp_ytds['perc_prior']=(comp_ytds['diff_prior']/comp_ytds['OffenseCount_Prior'])*100.00
        comp_ytds['perc_base']=(comp_ytds['diff_base']/comp_ytds['OffenseCount_Base'])*100.00
    
        comp_ytds.fillna(0,inplace=True)
    
        comp_ytds\
                     .set_index(group_dims).loc[:,['OffenseCount_Base','OffenseCount_Prior','OffenseCount']]\
                     .plot( kind='bar'
                          ,figsize=(20,10)
                          ,fontsize=16
                          ,rot=0
                          ,title=f'''Year-To-Date Violent, 2019,2022,2023\n{beati}'''
                          )
        comp_ytds['Beat']=beati            
        return comp_ytds
    #Done          

test=beat_analysis('21I10')

#All Beats - Based on GIS Geo data - not beats found in data
beats_agg=pd.DataFrame()
for beati in gis_beats.values:
    print(beati)    
    beat_row=beat_analysis(beati)
    beats_agg=pd.concat([ beats_agg
                         ,beat_row])  
      
beats_agg.sort_values('Beat').plot( x='Beat'\
               ,y='diff_prior'
               ,kind='bar'
               ,figsize=(16,8)
               ,title='Change in YTD(May) Violent Crime Counts\n2022 vs 2023')        
    
## Change from last year
beats_agg['change_cat']='none'
beats_agg.loc[beats_agg['diff_prior']>0,'change_cat']='up'
beats_agg.loc[beats_agg['diff_prior']<0,'change_cat']='down'
 
beats_agg['prior_change_grp']=0
beats_agg.loc[beats_agg['diff_prior']>0,'prior_change_grp']=1
beats_agg.loc[beats_agg['diff_prior']<0,'prior_change_grp']=-1
  
## Change from baseline year - likely 2019
beats_agg['change_cat2']='none'
beats_agg.loc[beats_agg['diff_base']>0,'change_cat2']='up'
beats_agg.loc[beats_agg['diff_base']<0,'change_cat2']='down'

beats_agg.groupby('change_cat')\
         .agg({'Overall':'count'})\
         .reset_index()\
         .plot( x='change_cat'
               ,y='Overall'
               ,kind='bar'
               ,figsize=(16,8)
               ,rot=0
               ,xlabel='Change Direction'
               ,title='Comparison of YTD HPD Beats from 2022 to 2023 ')

print(beats_agg.groupby('change_cat')\
               .agg({ 'change_cat':'count'
                     ,'diff_prior':'sum'}))
    
print('Over All Difference: ',beats_agg['diff_prior'].sum())    

print(beats_agg.groupby('change_cat2')\
               .agg({ 'change_cat2':'count'
                     ,'diff_base':'sum'}))
    
print('Over All Difference: ',beats_agg['diff_base'].sum())    

print( 'Top 10 Beats Down from last year\n'    
      ,beats_agg.set_index('Beat').sort_values('diff_prior').head(10)[['diff_prior']])
print( 'Top 10 Beats Up from last year\n'
      ,beats_agg.set_index('Beat').sort_values('diff_prior',ascending=False).tail(10)[['diff_prior']])

print( 'Top 10 Beats Down from 2019\n'   
      ,beats_agg.set_index('Beat').sort_values('diff_base').head(10)[['diff_base']])
print( 'Top 10 Beats Up from 2019\n'
      ,beats_agg.set_index('Beat').sort_values('diff_base',ascending=False).tail(10)[['diff_base']])


## Chloropleth!!!
import jenkspy
# Join the geojson file with Offense_Count Data
df_final=beat_gis.merge( beats_agg
                        ,left_on='Beats'
                        ,right_on='Beat'
                        ,how='outer')
 
df_final=df_final[~df_final['geometry'].isna()]

report_var='diff_prior'

min_bin=df_final[report_var].min()
max_bin=df_final[report_var].max()

m=folium.Map(location=[ 29.7604,-95.3698]
                       ,zoom_start=11
                       ,control_scale=True)

custom_scale = (df_final['diff_prior'].quantile((0,0.1,0.25,0.5,0.75,1))).tolist()

folium.Choropleth(
            geo_data=f'''C:/Users/chris/Downloads/{geofile}''',
            data=df_final,
            columns=['Beats', report_var],  #Here we tell folium to get the county fips and plot new_cases_7days metric for each county
            key_on='feature.properties.Beats', #Here we grab the geometries/county boundaries from the geojson file using the key 'coty_code' which is the same as county fips
            #threshold_scale=custom_scale, #use the custom scale we created for legend
            fill_color='PuBuGn',
            nan_fill_color="White", #Use white color if there is no data available for the county
            fill_opacity=0.7,
            line_opacity=0.2,
            legend_name='YTD Changes in Violent Crime Counts', #title of the legend
            highlight=True,
            use_jenks=False,
            #bins=3,
            bins=[min_bin,min_bin/2,0,max_bin/2,max_bin],
            line_color='black').add_to(m) 

folium.features.GeoJson(
                    data=df_final,
                    name='YTD Changes in Violent Crime Counts',
                    smooth_factor=2,
                    style_function=lambda x: {'color':'black','fillColor':'transparent','weight':0.5},
                    tooltip=folium.features.GeoJsonTooltip(
                        fields=['Beat',
                                'District',
                                'OffenseCount_Base',
                                'OffenseCount_Prior',
                                'OffenseCount',
                                'diff_prior',
                                'diff_base'
                               ],
                        aliases=["HPD Beat:",
                                 "District:",
                                 "Count 2019:",
                                 "Count 2022:",
                                 "Count 2023:",
                                 "Change from 2022:",
                                 "Change from 2019:"
                                ], 
                        localize=True,
                        sticky=False,
                        labels=True,
                        style="""
                            background-color: #F0EFEF;
                            border: 2px solid black;
                            border-radius: 3px;
                            box-shadow: 3px;
                        """,
                        max_width=800,),
                            highlight_function=lambda x: {'weight':3,'fillColor':'grey'},
                        ).add_to(m)  

m.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Beat_Map_test.html''')



# -*- coding: utf-8 -*-
"""
Created on Fri Jun 16 09:43:36 2023

@author: chris
"""
all_beats=multi_year['Beat'].dropna().drop_duplicates()

violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape'
                ,'Robbery'
                ,'Murder, non-negligent']

# violent_crimes=[ 'Aggravated Assault']

def beat_analysis(beati):
    print('-',beati,'-')
    ## TREND
    trend=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                         &( (multi_year['Beat'].str.contains(beati,na=False))
                           )]
    trend['NIBRSDescription']='Violent'

    _beat_df=nibrs_trendx( trend
                          ,'Violent'
                          ,12
                          ,_subtitle=f'''\n{beati}''')

    _min=_beat_df[f'''Rolling_12_Month'''].min()
    _max=_beat_df[f'''Rolling_12_Month'''].max()
    _start=_beat_df.loc[_beat_df['year_mon']==_beat_df['year_mon'].min()][f'''Rolling_12_Month'''].min()
    _finish=_beat_df.loc[_beat_df['year_mon']==_beat_df['year_mon'].max()][f'''Rolling_12_Month'''].min()
    
    print(_min,_max,_start,_finish)

    ## YEAR TO DATE
    # Filter and Aggregate
    bas_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2019-05-31')
                           &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2019-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    pri_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2022-05-31')
                           &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2022-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    cur_agg=trend.loc[ (trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')<='2023-05-31')
                           &(trend['RMSOccurrenceDate'].dt.strftime('%Y-%m-%d')>='2023-01-01')]\
            .groupby(group_dims)\
            .agg({'OffenseCount':'sum'})

    comp_ytds=bas_agg.join( pri_agg
                            ,on=group_dims
                            ,lsuffix='_Base'
                            ,rsuffix='_Prior')\
                      .join( cur_agg 
                            ,on=group_dims)\
                       .reset_index()      

    comp_ytds['diff_prior']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_Prior']
    comp_ytds['diff_base']=comp_ytds['OffenseCount']-comp_ytds['OffenseCount_Base']

    comp_ytds['perc_prior']=comp_ytds['diff_prior']/comp_ytds['OffenseCount_Prior']
    comp_ytds['perc_base']=comp_ytds['diff_base']/comp_ytds['OffenseCount_Base']

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

    #Premise           
 

#All Beats
beats_agg=pd.DataFrame()
for beati in all_beats.values:    
    beat_row=beat_analysis(beati)
    beats_agg=pd.concat([ beats_agg
                         ,beat_row])  
    
beats_agg.sort_values('Beat').plot( x='Beat'\
               ,y='diff_prior'
               ,kind='bar'
               ,figsize=(16,8)
               ,title='Change in YTD(May) Violent Crime Counts\n2022 vs 2023')        
    
beats_agg['change_cat']='none'
beats_agg.loc[beats_agg['diff_prior']>0,'change_cat']='up'
beats_agg.loc[beats_agg['diff_prior']<0,'change_cat']='down'
   
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
      ,beats_agg.set_index('Beat').sort_values('diff_prior').tail(10)[['diff_prior']])

print( 'Top 10 Beats Down from 2019\n'   
      ,beats_agg.set_index('Beat').sort_values('diff_base').head(10)[['diff_base']])
print( 'Top 10 Beats Up from 2019\n'
      ,beats_agg.set_index('Beat').sort_values('diff_base').tail(10)[['diff_base']])


show=beats_agg[['Beat','diff_prior']]

html=show.to_html(index=False,justify='center')
  
# write html to file
text_file = open("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/beats_tables.html", "w")
text_file.write(html)
text_file.close()


### Isolate some exemplars

G_beats=['18F10'
,'18F20'
,'18F30'
,'18F40'
,'18F50'
,'18F60'
,'20G10'
,'20G20'
,'20G30'
,'20G40'
,'20G50'
,'20G60'
,'20G70'
,'20G80'
,'1A50'
,'1A40'
,'2A50']

share=beats_agg.loc[beats_agg['Beat'].isin(G_beats)]

beat_analysis('18F30')
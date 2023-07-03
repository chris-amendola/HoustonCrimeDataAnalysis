# -*- coding: utf-8 -*-
"""
Created on Tue Jun 20 21:59:00 2023

@author: chris
"""
import folium
from folium.plugins import HeatMap

matplotlib.style.use('seaborn-dark-palette')

violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape'
                ,'Robbery'
                ,'Murder, non-negligent']

trend=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))]
trend['NIBRSDescription']='Violent'

ytd_over=YTD(trend,'Violent')

nibrs_trendx( trend 
             ,'Violent'
             ,12
             ,_subtitle='\nOverall')

trend=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))]

for nicat in violent_crimes:
    nibrs_trendx( trend 
                 ,nicat
                 ,12
                 ,_subtitle='\nOverall')

    YTD( trend 
                 ,nicat
                 ,_subtitle=f'''\n{nicat}''')

def mon_heatmap(start,end):
    df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,['ZIPCode','year','Premise','NIBRSDescription','OffenseCount','StreetNo','StreetName','MapLatitude','MapLongitude']]
    
    df['Address']=df['StreetNo']+' '+df['StreetName']+' - '+df['Premise']
    df.dropna(inplace=True)
    
    m=folium.Map(location=[ df.MapLatitude.mean() 
                           ,df.MapLongitude.mean()]
                           ,zoom_start=11
                           ,control_scale=True)
    
    folium.GeoJson('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson').add_to(m)
     
    map_values=df[['MapLatitude','MapLongitude','OffenseCount']]
    
    data=map_values.values.tolist()
    
    hm=HeatMap(data,
                  min_opacity=0.05, 
                  max_opacity=0.9, 
                   radius=25).add_to(m)
    
    hm.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_HeatMap_{start}.html''')

mon_heatmap('01','02')
mon_heatmap('02','03')
mon_heatmap('03','04')
mon_heatmap('04','05')
mon_heatmap('05','06')   

def map_plot(start,end):
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
    
    df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,['ZIPCode','year','Premise','NIBRSDescription','OffenseCount','StreetNo','StreetName','MapLatitude','MapLongitude']]
    
    df['Address']=df['StreetNo']+' '+df['StreetName']+' - '+df['Premise']
    df.dropna(inplace=True)
    
    actual_cats=df.groupby(['Premise'])\
                  .agg({'OffenseCount':'sum'})\
                  .reset_index()\
                  .sort_values('OffenseCount',ascending=False).head(18)['Premise']   
    
    colorkey=dict(zip(actual_cats,all_colors))
    color_crime=dict(zip(violent_crimes,all_colors))
    
    print(f'Before dropping NaNs and dupes\t:\tdf.shape = {df.shape}')
    df.dropna(inplace=True)
    print(f'After dropping NaNs\t:\tdf.shape = {df.shape}')
    
    m=folium.Map(location=[ df['MapLatitude'].mean()
                           ,df['MapLongitude'].mean()]
                 ,zoom_start=11 
                 ,tiles='OpenStreet Map')
    
    folium.GeoJson('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson').add_to(m)
     
    for _, row in df.iterrows():
        try:
            icon_color=color_crime[row['NIBRSDescription']]
        except:
            #Catch nans
            icon_color='lightgray'
            
        folium.CircleMarker(
            location=[row.MapLatitude, row.MapLongitude],
            radius=5,
            color=icon_color,
            fill=True,
            fill_colour=icon_color,
            tooltip=row.Address
            
        ).add_to(m)
    
    ## add html legend
    legend_html = """<div style="background-color: #ABBAEA; position:fixed; top:10px; right:10px; border:2px solid black; z-index:9999; font-size:14px;">&nbsp;<b>"""+'NIBRSDescription'+""":</b><br>"""
    for i in color_crime:    
         legend_html = legend_html+"""&nbsp;<i class="fa fa-circle 
         fa-1x" style="color:"""+color_crime[i]+"""">
         </i>&nbsp;"""+str(i)+"""<br>"""
    legend_html = legend_html+"""</div>"""
    m.get_root().html.add_child(folium.Element(legend_html))
        
    m.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_{start}.html''')

map_plot('01','02')
map_plot('02','03')
map_plot('03','04')
map_plot('04','05')
map_plot('05','06')   

def cluster_incidents(start,end,n_neur=12):
    X=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,["MapLatitude","MapLongitude"]].reset_index(drop=True)
    
    
    print(f'Before dropping NaNs and dupes\t:\tdf.shape = {X.shape}')
    X.dropna(inplace=True)
    print(f'After dropping NaNs\t:\tdf.shape = {X.shape}')
    
    som_shape=(1,12)
    ## scale data
    scaler=preprocessing.StandardScaler()
    preprocessed=scaler.fit_transform(X.values)
    
    # Initialization and training
    som=minisom.MiniSom( som_shape[0]
                        ,som_shape[1]
                        ,preprocessed.shape[1]
                        ,sigma=.5
                        ,learning_rate=.5
                        ,neighborhood_function='gaussian'
                        ,random_seed=55)
    
    som.train_batch( preprocessed
                    ,200
                    ,verbose=True)
    
    # each neuron represents a cluster
    winner_coordinates=np.array([som.winner(x) for x in preprocessed]).T
    # with np.ravel_multi_index we convert the bidimensional
    # coordinates to a monodimensional index
    cluster_index=np.ravel_multi_index( winner_coordinates
                                       ,som_shape)
    
    # plotting the clusters using the first 2 dimentions of the data
    for c in np.unique(cluster_index):
        plt.scatter( preprocessed[cluster_index == c, 0]
                    ,preprocessed[cluster_index == c, 1]
                    ,label='cluster='+str(c)
                    ,alpha=.7)
    
    # plotting centroids
    for centroid in som.get_weights():
        # print(centroid)
        # print(scaler.inverse_transform(centroid))
        plt.scatter( centroid[:, 0]
                    ,centroid[:, 1]
                    ,marker='x'
                    ,s=5
                    ,linewidths=5
                    ,color='k'
                    ,label='centroid')
    plt.legend();
    
    X['cluster']=cluster_index.tolist()
    X.info()
    color_clus=dict(zip([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],all_colors))
    
    X['color']=X['cluster'].map(color_clus)
    
    X.plot(x='MapLongitude',y='MapLatitude',kind='scatter',c='color')
    
    
    clu_m=folium.Map(location=[ X['MapLatitude'].mean()
                               ,X['MapLongitude'].mean()]
                 ,zoom_start=11
                 ,tiles='OpenStreet Map')
    
    folium.GeoJson('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson').add_to(clu_m)
     
    for _, row in X.iterrows():
        try:
            icon_color=color_clus[row['cluster']]
        except:
            #Catch nans
            icon_color='lightgray'
            
        folium.CircleMarker(
            location=[row.MapLatitude, row.MapLongitude],
            radius=5,
            color=icon_color,
            fill=True,
            fill_colour=icon_color
        ).add_to(clu_m)
    
    for centroid in som.get_weights():    
        cent=scaler.inverse_transform(centroid)
        for coords in cent:
            print(coords[0],'-',coords[1],'\n')
            folium.Marker(
                location=[coords[0], coords[1]],
            ).add_to(clu_m)
        
    clu_m.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_Cluster_{start}.html''')


cluster_incidents('01','02')
cluster_incidents('02','03')
cluster_incidents('03','04')
cluster_incidents('04','05')
cluster_incidents('05','06')   

## DEV
def map_plot(start,end):
    all_colors=[ 'red'
                ,'yellow'
                ,'blue'
                ,'orange'
                ,'gray'
                ,'green'
                ,'purple'
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
    
    df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,['ZIPCode','year_mon','Premise','NIBRSDescription','OffenseCount','StreetNo','StreetName','MapLatitude','MapLongitude']]
    
    df['Address']=df['StreetNo']+' '+df['StreetName']+' - '+df['Premise']
    df.dropna(inplace=True)
    
    actual_ym=df.groupby(['year_mon'])\
                  .agg({'OffenseCount':'sum'})\
                  .reset_index()\
                  .sort_values('OffenseCount',ascending=False).head(3)['year_mon']   
    
    colorkey=dict(zip(actual_ym,all_colors))
    color_time=dict(zip(actual_ym,all_colors))
    
    print(f'Before dropping NaNs and dupes\t:\tdf.shape = {df.shape}')
    df.dropna(inplace=True)
    print(f'After dropping NaNs\t:\tdf.shape = {df.shape}')
    
    m=folium.Map(location=[ df['MapLatitude'].mean()
                           ,df['MapLongitude'].mean()]
                 ,zoom_start=11 
                 ,tiles='OpenStreet Map')
    
    folium.GeoJson('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson').add_to(m)
     
    for _, row in df.iterrows():
        try:
            icon_color=color_time[row['year_mon']]
        except:
            #Catch nans
            icon_color='lightgray'
            
        folium.CircleMarker(
            location=[row.MapLatitude, row.MapLongitude],
            radius=5,
            color=icon_color,
            fill=True,
            fill_colour=icon_color,
            tooltip=row.Address
            
        ).add_to(m)
    
    ## add html legend
    legend_html = """<div style="background-color: #ABBAEA; position:fixed; top:10px; right:10px; border:2px solid black; z-index:9999; font-size:14px;">&nbsp;<b>"""+'year_mon'+""":</b><br>"""
    for i in color_time:    
         legend_html = legend_html+"""&nbsp;<i class="fa fa-circle 
         fa-1x" style="color:"""+color_time[i]+"""">
         </i>&nbsp;"""+str(i)+"""<br>"""
    legend_html = legend_html+"""</div>"""
    m.get_root().html.add_child(folium.Element(legend_html))
        
    m.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_time.html''')

#map_plot('05','06')

## Premsie
def premise( start
            ,end
            ,_subtitle=''):
    
    df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,['Premise','NIBRSDescription','OffenseCount','year_mon']]
    
    agg_df=df.groupby('Premise')\
             .agg({'OffenseCount':'sum'})\
             .reset_index()    
             
    agg_df.plot( kind='bar'
                ,x='Premise'
                ,figsize=(12,6)
                ,title=f'''Violent Incident Counts By Premise{_subtitle}''')
      
    print( 'Top 5 Premises of Violent Crimes\n'
          ,agg_df[['Premise','OffenseCount']]\
              .sort_values('OffenseCount',ascending=False)['Premise'].head(5))  



premise('01','02',_subtitle='\nJanuary 2023')
premise('02','03',_subtitle='\nFebruray 2023')
premise('03','04',_subtitle='\nMarch 2023')
premise('04','05',_subtitle='\nApril 2023')
premise('05','06',_subtitle='\nMay 2023')


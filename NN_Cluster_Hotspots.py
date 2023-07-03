# -*- coding: utf-8 -*-
"""
Created on Thu Jun 29 17:58:58 2023

@author: chris
"""
import numpy as np

def cluster_incidents(start,end,n_neur=12):
    
    X=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                          &(multi_year['RMSOccurrenceDate']>=f'''{start}/01/2023''')
                          &(multi_year['RMSOccurrenceDate']<f'''{end}/01/2023''')
                        ,["MapLatitude","MapLongitude"]].reset_index(drop=True)
    
    
    print(f'Before dropping NaNs and dupes\t:\tdf.shape = {X.shape}')
    X.dropna(inplace=True)
    print(f'After dropping NaNs\t:\tdf.shape = {X.shape}')
    print(f'After dropping NaNs\t:\tdf.shape = {X.shape}')
    #print(np.sqrt(X.shape[0]))
    
    
    som_shape=(4,4)
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
                        ,random_seed=22)
    
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
    X['count']=1
    clus_sum=X.groupby('cluster').agg({'count':'sum'})
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
        
        #icon_color='green'  
        
        folium.CircleMarker(
            location=[row.MapLatitude, row.MapLongitude],
            radius=5,
            color=icon_color,
            fill=True,
            fill_colour=icon_color
        ).add_to(clu_m)
    
    k=0
    for centroid in som.get_weights():
        cent=scaler.inverse_transform(centroid)
        for coords in cent:
            print(k)
            print(clus_sum.loc[clus_sum.index==k]['count'].values)
            #print(coords[0],'-',coords[1],'\n')
            folium.CircleMarker(
                location=[coords[0], coords[1]],
                radius=16,
                color='black',
                fill='black',
                popup=k,
            ).add_to(clu_m)
            folium.Marker(
                          location=[coords[0], coords[1]],
                          popup=k,
                          icon=folium.DivIcon(icon_size=(20,20),
                          icon_anchor=(4,16),html=f"""<div style="font-family: arial bold; color: black;font-size: 14pt">{k}</div>""")
                       ).add_to(clu_m)
            k=k+1
            
    clu_m.save(f'''C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_Cluster_{start}_B.html''')
    return clus_sum

import folium
from folium.plugins import HeatMap

matplotlib.style.use('seaborn-dark-palette')

violent_crimes=[ 'Aggravated Assault'
                ,'Forcible rape'
                ,'Robbery'
                ,'Murder, non-negligent']


test1=cluster_incidents('01','02')
test2=cluster_incidents('02','03')
test3=cluster_incidents('03','04')
test4=cluster_incidents('04','05')
test5=cluster_incidents('05','06')   
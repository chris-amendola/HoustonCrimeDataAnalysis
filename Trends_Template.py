# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 15:32:51 2023

@author: chris
"""
import folium
from folium.plugins import HeatMap

violent_crimes=['Drug, narcotic violations']

trend=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))]

nibrs_trendx( trend
             ,'Drug, narcotic violations'
             ,12
             ,_subtitle='\nOverall')

df=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))
                      &(multi_year['RMSOccurrenceDate']>='02/01/2023')
                      &(multi_year['RMSOccurrenceDate']<datetime.now())
                    ,['ZIPCode','year','Premise','NIBRSDescription','OffenseCount','StreetNo','StreetName','MapLatitude','MapLongitude']]

df['Address']=df['StreetNo']+' '+df['StreetName']+' - '+df['Premise']
df.dropna(inplace=True)

m=folium.Map(location=[ df.MapLatitude.mean() 
                       ,df.MapLongitude.mean()]
                       ,zoom_start=6
                       ,control_scale=True)

folium.GeoJson('C:/Users/chris/Downloads/COH_ADMINISTRATIVE_BOUNDARY_-_MIL.geojson').add_to(m)
 
map_values=df[['MapLatitude','MapLongitude','OffenseCount']]

data=map_values.values.tolist()

hm=HeatMap(data,
              min_opacity=0.05, 
              max_opacity=0.9, 
              radius=25).add_to(m)

hm.save("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_HeatMap.html")
    

all_colors=[ 'red'
            ,'gray'
            ,'blue'
            ,'green'
            ,'purple'
            ,'orange'
            ,'pink'
            ,'yellow'
            ,'gray'
            ,'magenta'
            ,'chocolate'
            ,'brown'
            ,'aqua'
            ,'violet'
            ,'wheat'
            ,'darkornage']

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
             ,zoom_start=9 
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
    
m.save("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent.html")

#####
X=df.loc[:,["MapLatitude","MapLongitude"]].reset_index(drop=True)

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
             ,zoom_start=9 
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
    
clu_m.save("C:/Users/chris/Documents/Random_Nextdoor/My_Crime_Analysis - 05.04.23/Group/Violent_Cluster.html")

#Premise  
prem_data=multi_year.loc[ (multi_year['NIBRSDescription'].isin(violent_crimes))]\
              .groupby(['year','Premise'])\
              .agg({'OffenseCount':'sum'})\
              .reset_index()                 

piv_data=prem_data.pivot_table( columns='year'
                 ,index=['Premise']
                 ,values='OffenseCount')

for ayear in [2019,2020,2021,2022,2023]:
    piv_data[f'''{ayear}_prop''']=piv_data[ayear]/piv_data[ayear].sum()
    
    piv_data.plot(y=ayear
                                       ,kind='bar'
                                       ,title=f'''Year: {ayear}'''
                                       ,figsize=(10,8),ylim=(0,15000))
     
for ayear in [2019,2020,2021,2022,2023]:    
    piv_data.plot(y=f'''{ayear}_prop'''
                                       ,kind='bar'
                                       ,title=f'''Year: {ayear}'''
                                       ,figsize=(10,8),ylim=(0,1))
    
piv_data['delprop_19_23']=piv_data['2023_prop']-piv_data['2019_prop']
piv_data['delprop_22_23']=piv_data['2023_prop']-piv_data['2022_prop']    
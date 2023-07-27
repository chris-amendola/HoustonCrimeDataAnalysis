# install the kohonen package
#install.packages("kohonen")

# load the kohonen package
library("kohonen")

crimes_filtered<-multi_year[NIBRSDescription %chin% violent_crimes]%>%
                .[ (!is.na(MapLongitude))
                  |(!is.na(MapLatitude))]

coords<-scale(crimes_filtered[,.(MapLongitude,MapLatitude)])

grid<-somgrid( xdim=4
              ,ydim=4
              ,topo="hexagonal")

model<-som( coords
           ,grid=grid
           ,rlen=100
           ,alpha=c(0.05,0.01))

names(model)
testa<-as.data.frame(model$codes)

test<-cbind(as.data.frame(model$unit.classif),coords)
test2<-cbind(crimes_filtered,test)

geo_plot(data=test2)



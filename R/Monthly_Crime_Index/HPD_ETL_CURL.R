pacman::p_load(
                readxl
               ,excel.link
               ,glue
               ,DBI)

check_date<-"2023-11-30"
curl_source<-'C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DATA/curl'

db_path<-'C:/Users/chris/Documents/Houston_Crime_Data_Analysis/DATA'
db_name<-'HPD_NIBRS'

create_db<-function( db_path
                    ,db_name){
  
    cr_db<-dbConnect( RSQLite::SQLite()
                     ,glue("{db_path}/{db_name}"))
    dbDisconnect(cr_db)
}

#create_db(db_path,db_name)

check_date<-"2023-11-30"

curl_it<-function( url_parm
                  ,dest_parm
                  ,sheet_name
                  ){
  
  url<-url_parm
  destfile<-dest_parm
  curl::curl_download(url, destfile)
  
  raw_df<-xl.read.file( filename=glue('{curl_source}/{dest_parm}')
                       ,xl.sheet=sheet_name
                       ,top.left.cell = "A1")

  return(raw_df)  
}

setwd(curl_source)

year_23<-curl_it( "https://www.houstontx.gov/police/cs/xls/NIBRSPublicView2023.xlsx"
                 ,"NIBRSPublicView2023.xlsx"
                 ,"CrimeData2023")

max_date<-max(year_23$RMSOccurrenceDate)


if (max_date>check_date){
  print("NEW DATA!!")
  
  year_22<-curl_it( "https://www.houstontx.gov/police/cs/xls/NIBRSPublicView2022.xlsb"
                   ,"NIBRSPublicView2022.xlsb"
                   ,"CrimeData2022")

  year_21<-curl_it( "https://www.houstontx.gov/police/cs/xls/NIBRSPublicView2021.xlsb"
                   ,"NIBRSPublicView2021.xlsb"
                   ,"CrimeData2021")

  year_20<-curl_it( "https://www.houstontx.gov/police/cs/xls/NIBRSPublicView2020.xlsb"
                   ,"NIBRSPublicView2020.xlsb"
                   ,"CrimeData2020")

  year_19<-curl_it( "https://www.houstontx.gov/police/cs/xls/NIBRSPublicView2019.xlsb"
                   ,"NIBRSPublicView2019.xlsb"
                   ,"CrimeData2019")
  
  raw_db<- dbConnect( RSQLite::SQLite()
                     ,glue('{db_path}/{db_name}'),extended_types = TRUE)
  
  dbWriteTable(raw_db, "year_23", year_23,overwrite=TRUE)
  dbWriteTable(raw_db, "year_22", year_22,overwrite=TRUE)
  dbWriteTable(raw_db, "year_21", year_21,overwrite=TRUE)
  dbWriteTable(raw_db, "year_20", year_20,overwrite=TRUE)
  dbWriteTable(raw_db, "year_19", year_19,overwrite=TRUE)
  
  dbDisconnect(raw_db)
  
}

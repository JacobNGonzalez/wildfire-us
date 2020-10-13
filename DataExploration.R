library(RSQLite)
library(ncdf4)
library(tidync)
library(dbplyr)
library(zoo)

# connect to the SQLite db
conn_fpa <- dbConnect(RSQLite::SQLite(), "./Data/DBs/FPA_FOD_20170508.sqlite")
dbListTables(conn_fpa)

# create a data frame from the 'Fires' table (limit to 100 entries for now)
data_fires <- dbGetQuery(conn_fpa, "SELECT * FROM Fires LIMIT 100")
head(data_fires)

#find the range of longs and lats
# need to readdress here to check the long/lat conversion
min_lat <- as.numeric(dbGetQuery(conn_fpa, "SELECT MIN(LATITUDE) FROM Fires"))
max_lat <- as.numeric(dbGetQuery(conn_fpa, "SELECT MAX(LATITUDE) FROM Fires"))
min_lon <- as.numeric(dbGetQuery(conn_fpa, "SELECT MIN(LONGITUDE) FROM Fires"))+360
max_lon <- as.numeric(dbGetQuery(conn_fpa, "SELECT MAX(LONGITUDE) FROM Fires"))+360

#explore the air temperature NetCDF file
data_airtemp <- nc_open('./Data/air.mon.mean.v501.nc')
print(data_airtemp)

#view details on the individual features
#note: missing value isn't simply, but "-9.97e+36"
str(ncatt_get(data_airtemp, 'air'))

#note: time is counted at intervals of one month
str(ncatt_get(data_airtemp, 'time'))

#view the structure of the air temp data portion
# -long, lat, months
array_air <- ncvar_get(data_airtemp, 'air')
str(array_air)

lon_air <- ncvar_get(data_airtemp, 'lon')
lat_air <- ncvar_get(data_airtemp, 'lat')
date_air <- ncvar_get(data_airtemp, 'time')

#the discovery date data is given with an origin date in the original Julian format,
#so the origin is Jan 1, 4713 BC. The date library doesn't account for BCE, so we must take the days
#off manually in order to convert it to a more friendly format. 
#Taking off 2440588 days gets us to the more typical 1970-01-01 origin.
data_fires$newDate <- as.Date(data_fires$DISCOVERY_DATE, origin = structure(-2440588, class = "Date"))



#let's try expirementing with TidyNc to save some time and get a dataframe of the air temps
tidy_air <- tidync('./Data/air.mon.mean.v501.nc')

hf_air <- tidy_air %>%
  hyper_filter(
    time = time >= 807192 & time <= 1016832,
    lat = lat <= max_lat & lat >= min_lat, 
    lon = lon <= max_lon & lon >= min_lon)

df_air <- hf_air %>% hyper_tibble() %>% dplyr::select(time, air, lat, lon)

df_air_tail <- tail(df_air)

df_air_tail$newDate <- as.POSIXct(df_air_tail$time*3600, origin = '1900-01-01')
df_air_tail$newDate <- as.yearmon(df_air_tail$newDate)


df_air$newDate <- as.POSIXct(df_air$time*3600, origin = '1900-01-01')


as.POSIXct(805920*3600, origin = '1900-01-01')

as.POSIXct(1016813*3600, origin = '1900-01-01')


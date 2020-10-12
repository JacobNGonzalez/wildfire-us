library(RSQLite)
library(ncdf4)
# connect to the SQLite db
conn_fpa <- dbConnect(RSQLite::SQLite(), "./Data/DBs/FPA_FOD_20170508.sqlite")
dbListTables(conn_fpa)

# create a data frame from the 'Fires' table (limit to 100 entries for now)
data_fires <- dbGetQuery(conn_fpa, "SELECT * FROM Fires LIMIT 100")
head(data_fires)

dbDisconnect(conn)

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

days2date <- function(v, origin='1900-01-01'){
  origin <- as.Date(origin)
  out <- list()
  out <- lapply(v, function(x) seq(origin, by = paste(x, 'day'), length=2)[2])
  do.call(c, out)           
}

date2days <- function(v, origin='1900-01-01'){
  v <- as.Date(v)
  origin <- as.Date(origin)
  sapply(v, function(x) (x - origin)[[1]])
}
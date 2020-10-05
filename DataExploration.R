library(RSQLite)

# connect to the SQLite db
conn_fpa <- dbConnect(RSQLite::SQLite(), "./Data/FPA_FOD_20170508.sqlite")
dbListTables(conn_fpa)

# create a data frame from the 'Fires' table (limit to 100 entries for now)
data_fires <- dbGetQuery(conn_fpa, "SELECT * FROM Fires LIMIT 100")
head(data_fires)






dbDisconnect(conn)


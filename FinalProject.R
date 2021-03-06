



setwd("./Documents/Master/Data Mining/Project/Pittsburgh-Bike-Share-Project/")



### Get the data

setwd("./data/")



library(lubridate)
library(dplyr)
library(ggplot2)



## Read The data
### stations data
stations <- read.csv("HealthyRideStations2015.csv")



## 2015 Q3

rentalQ153 <- read.csv("HealthyRideRentals 2015 Q3.csv",na.strings= c("999", "NA", " ", ""))  


### Change the data 

rentalQ153$StartTime <- strptime(rentalQ153$StartTime, format="%m/%d/%Y %H:%M")
rentalQ153$StopTime <- strptime(rentalQ153$StopTime, format="%m/%d/%Y %H:%M")

# rentalQ153$StartTime <- as.POSIXct(rentalQ153$StartTime, format="%m/%d/%Y %H:%M")
# rentalQ153$StopTime <- as.POSIXct(rentalQ153$StopTime, format="%m/%d/%Y %H:%M")





## 2015 Q4

## Converting from xls to csv

# require(gdata)
# ## install support for xlsx files
# installXLSXsupport()
# excelFile <- ("./HealthyRideRentals 2015 Q4.xlsx")
# ## note that the perl scripts that gdata uses do not cope well will tilde expansion
# ## on *nix machines. So use the full path. 
# numSheets <- sheetCount(excelFile, verbose=TRUE)
# 
# for ( i in 1:numSheets) {
#   mySheet <- read.xls(excelFile, sheet=i)
#   write.csv(mySheet, file=paste(i, "csv", sep="."), row.names=FALSE)
# }

rentalQ154 <- read.csv("HealthyRideRentals 2015 Q4.csv", na.strings= c("999", "NA", " ", ""))  
rentalQ154$StartTime <- strptime(rentalQ154$StartTime, format="%Y-%m-%d %H:%M:%S")
rentalQ154$StopTime <- strptime(rentalQ154$StopTime, format="%Y-%m-%d %H:%M:%S")

# rentalQ154$StartTime <- as.POSIXct(rentalQ154$StartTime)
# rentalQ154$StopTime <- as.POSIXct(rentalQ154$StopTime)





## 2016 Q1

## Converting from xls to csv

# require(gdata)
# ## install support for xlsx files
# installXLSXsupport()
# excelFile <- ("./HealthyRide Rentals 2016 Q1.xlsx")
# ## note that the perl scripts that gdata uses do not cope well will tilde expansion
# ## on *nix machines. So use the full path.
# 
# 
# mySheet <- read.xls(excelFile)
# write.csv(mySheet, file=paste("HealthyRide Rentals 2016 Q1","csv", sep="."), row.names=FALSE)

rentalQ161 <- read.csv("HealthyRide Rentals 2016 Q1.csv", na.strings= c("999", "NA", " ", ""))  
## Make sure they have the same colunm names 
names(rentalQ161) <- c(names(rentalQ153))

rentalQ161$StartTime <- strptime(rentalQ161$StartTime, format="%Y-%m-%d %H:%M:%S")
rentalQ161$StopTime <- strptime(rentalQ161$StopTime, format="%Y-%m-%d %H:%M:%S")

# rentalQ161$Starttime <- as.POSIXct(rentalQ161$Starttime,format="%Y-%m-%d %H:%M:%S")
# rentalQ161$Stoptime <- as.POSIXct(rentalQ161$Stoptime,format="%Y-%m-%d %H:%M:%S")








## binding the data together

bike <- rbind(rentalQ153,rentalQ154,rentalQ161)

bike$TripId <- as.factor(bike$TripId)
bike$BikeId <- as.factor(bike$BikeId)
bike$FromStationId <- as.factor(bike$FromStationId)
bike$ToStationId <- as.factor(bike$ToStationId)




## Splitting the date 



# bike <- bike %>% mutate(
#   year = format(as.POSIXct(StartTime), format = "%Y"),
#   month = format(as.POSIXct(StartTime), format = "%m"),
#   day = format(as.POSIXct(StartTime), format = "%d"),
#   hour = format(as.POSIXct(StartTime), format= "%H")
# )


set_up_features <- function(df) {
  ### Start Time 
  df$StartTime <- strptime(df$StartTime, format="%Y-%m-%d %H:%M:%S")
  df$StartHour <- as.factor(df$StartTime$hour)
  df$StartDay <-  as.factor(df$StartTime$mday)
  df$StartWday <- as.factor(df$StartTime$wday)
  df$StartMonth <- as.factor(df$StartTime$mon+1) ## starts from 0
  df$StartYear <- as.factor(df$StartTime$year + 1900)
  
  ### Stop Time
  df$StopTime <- strptime(df$StopTime, format="%Y-%m-%d %H:%M:%S")
  df$StopHour <- as.factor(df$StopTime$hour)
  df$StopDay <-  as.factor(df$StopTime$mday)
  df$StopWday <- as.factor(df$StopTime$wday)
  df$StopMonth <- as.factor(df$StopTime$mon+1) ## starts from 0
  df$StopYear <- as.factor(df$StopTime$year + 1900)
  
  df
}

bike <- set_up_features(bike)
  


## Make a summeary for the missing values 

na_data <- sapply(bike, function(x) sum(length(which(is.na(x)))))
na_data




bike$FromStationName[which(is.na(bike$FromStationId))]


bike$FromStationId[which(is.na(bike$FromStationName))]

## I guss we should just drop them



#detach("package:plyr", unload=TRUE) 


### Remove all NA values 

bike <- na.omit(bike)


## Remove the station "Transit" and "Healthy Ride Hub"

## 687
 bike %>% 
  select(TripId, FromStationId) %>% 
    filter(FromStationId %in% c(1050,1051)) %>% 
      summarise(n())

## 790
bike %>%
    select(TripId, ToStationId) %>%
    filter(ToStationId %in% c(1050,1051)) %>%
    summarise(n())



### Drop these values 
 bike <- bike[!bike$FromStationId %in% c(1050,1051) & !bike$ToStationId %in% c(1050,1051),]




# # weather$DATE <- as.factor(weather$DATE$year + 1900)
# set_up_featuresDate <- function(df) {
#   df$day <-  as.factor(df$date$mday)
#   df$month <- as.factor(df$date$mon+1) ## starts from 0
#   df$year <- as.factor(df$date$year + 1900)
#   df
# }
# 
# weather <- set_up_featuresDate(weather)




# weather <- weather[,-1]





# bike1 <- merge(weather, bike, by = c("day","month","year"))
# bike1 <- join(bike, weather_holidays,  by=c("Day",'Month','Year'), type="inner")
# semi_join(bike, weather)



## Write a csv file "bike.csv"

write.csv(bike, file = "./bike.csv", row.names = FALSE)



## Calcuate the counts
# by Hour, Day, Month, Year
# inclue the From station Id
starttime <- bike[,c(6,11,12,14,15)]
stoptime <- bike[,c(8,16,17,19,20)]



## Calcuate the counts

# starttime <- count_(starttime, c('StartHour','StartDay','StartMonth','StartYear'))
# stoptime <- count_(stoptime,  c('StopHour','StopDay','StopMonth','StopYear'))

starttime <- starttime %>% count(FromStationId, StartHour,StartDay, StartMonth, StartYear)
stoptime <- stoptime %>% count(ToStationId, StopHour, StopDay, StopMonth, StopYear)


## Aggregation for Hour and FromStationId and ToStationid


aggregate_starttime_hour <- starttime %>% 
  group_by(FromStationId,StartHour,StartDay,StartMonth,StartYear) %>% 
  summarise_each(funs(sum), n) %>% 
  arrange(desc(n))

aggregate_stoptime_hour <- stoptime %>%
  group_by(ToStationId,StopHour, StopDay, StopMonth, StopYear) %>%
  summarise_each(funs(sum), n) %>%
  arrange(StopYear, StopMonth)


## Aggregation per day and FromStationId and ToStationid
## used for classification

aggregate_starttime_day <- starttime %>% 
  group_by(FromStationId,StartDay,StartMonth,StartYear) %>% 
  summarise_each(funs(sum), n) %>% 
  arrange(StartYear, StartMonth)

aggregate_stoptime_day <- stoptime %>%
  group_by(ToStationId,StopDay, StopMonth, StopYear) %>%
  summarise_each(funs(sum), n) %>%
  arrange(StopYear, StopMonth)





library(plyr)

### Weather 

### Holiday column 1 means it is either a holiday or a weekend 
### Weekend 1 = yes , 0 = no
## Types 1 = Sunny, 2 = Rain, 3 = Snow

# weather <- read.csv("weather.csv")
weather_holidays <- read.csv("weather_holiday.csv", stringsAsFactors = TRUE)
weather_holidays$Day <- as.factor(weather_holidays$Day)
weather_holidays$Month <- as.factor(weather_holidays$Month)
weather_holidays$Year <- as.factor(weather_holidays$Year)
weather_holidays$Holiday <- as.factor(weather_holidays$Holiday)
weather_holidays$Weekend <- mapvalues(weather_holidays$Weekend, from = c('yes','no'), to = c(1,0))
weather_holidays$Types <- mapvalues(weather_holidays$Types, from = c('Sunny','Rain','Snow'), to = c(1,2,3))



### Merge the aggregate_starttime_hour with the holdiay and the weather 
### This is just used for the prediction 

bike_final <-merge(aggregate_starttime_hour, weather_holidays, by.x = c('StartDay','StartMonth','StartYear'), by.y = c('Day','Month','Year'))



## For classification we need two separete files to find out the unbalance problem 

bike_starttime <- merge(aggregate_starttime_day, weather_holidays, by.x = c('StartDay','StartMonth','StartYear'), by.y = c('Day','Month','Year'))
bike_starttime <- arrange(bike_starttime, StartYear, StartMonth, StartDay)


bike_stoptime <- merge(aggregate_stoptime_day, weather_holidays, by.x = c('StopDay','StopMonth','StopYear'), by.y = c('Day','Month','Year'))
bike_stoptime <- arrange(bike_stoptime, StopYear, StopMonth, StopDay)




write.csv(bike_final, file = "./bike_final.csv", row.names = FALSE)
write.csv(bike_starttime, file = "./bike_starttime.csv", row.names = FALSE)
write.csv(bike_stoptime, file = "./bike_stoptime.csv", row.names = FALSE)





####################### Warning ####################################
##### The next section is just for data exploration  #################



## Get the weather and holidays
holiday <- weather_holidays[, c('Day','Month','Year','Weekend','Holiday')]

## Merging them by 
starttime_holiday <- merge(starttime, holiday, by.x = c('StartDay','StartMonth','StartYear'), by.y = c('Day','Month','Year'))

stoptime_holiday <- merge(stoptime, holiday, by.x = c('StopDay','StopMonth','StopYear'), by.y = c('Day','Month','Year'))


### Grouping by day to make useful viusalization 

aggregate_starttime_day_weatherHoliday <- merge(aggregate_starttime, weather_holidays, by.x = c('StartDay','StartMonth','StartYear'), by.y = c('Day','Month','Year'))

aggregate_starttime_day_weatherHoliday <- aggregate_starttime_day_weatherHoliday %>% arrange(StartYear,StartMonth,StartDay)

aggregate_starttime_day_weatherHoliday$Types <- as.integer(aggregate_starttime_day_weatherHoliday$Types)
aggregate_starttime_day_weatherHoliday$Weekend <- as.integer(aggregate_starttime_day_weatherHoliday$Weekend)
aggregate_starttime_day_weatherHoliday$Holiday <- as.integer(aggregate_starttime_day_weatherHoliday$Holiday)

View(aggregate_starttime_day_weatherHoliday)





### Split them based on the holiday holiday
starttime_holiday_split <- split(starttime_holiday, starttime_holiday$Holiday)

starttime_holiday_no <- starttime_holiday_split[[1]]
starttime_holiday_yes <- starttime_holiday_split[[2]]

stoptime_holiday_split <- split(stoptime_holiday, stoptime_holiday$Holiday)

stoptime_holiday_no <- stoptime_holiday_split[[1]]
stoptime_holiday_yes <- stoptime_holiday_split[[2]]


### aggregating with hour
starttime_holiday_yes_hour <- aggregate(n ~ StartHour , data = starttime_holiday_yes, sum)
starttime_holiday_no_hour <- aggregate(n ~ StartHour, data = starttime_holiday_no, sum)

stoptime_holiday_yes_hour <- aggregate(n ~ StopHour, data = stoptime_holiday_yes, sum)
stoptime_holiday_no_hour <- aggregate(n ~ StopHour, data = stoptime_holiday_no, sum)



## Merging 

startstoptime_DMY <- merge(aggregate_starttime,aggregate_stoptime, by.x = c("StartDay","StartMonth","StartYear"), by.y = c("StopDay","StopMonth","StopYear"))

startstop_holiday_yes_hour <- merge(starttime_holiday_yes_hour, stoptime_holiday_yes_hour, by.x = "StartHour", by.y = "StopHour")

startstop_holiday_no_hour <- merge(starttime_holiday_no_hour, stoptime_holiday_no_hour, by.x = "StartHour", by.y = "StopHour")



## Renaming 
startstoptime_DMY <- rename(startstoptime_DMY, c("n.x"="Out", "n.y"="In"))
startstop_holiday_yes_hour <- rename(startstop_holiday_yes_hour,  c("n.x"="Out", "n.y"="In"))
startstop_holiday_no_hour <- rename(startstop_holiday_no_hour,  c("n.x"="Out", "n.y"="In"))


## Graphs


ggplot(aggregate_starttime, aes(x=n , fill = as.factor(StartYear))) + geom_density()
ggplot(aggregate_starttime, aes(x=log(n) , fill = as.factor(StartMonth))) + geom_density()
ggplot(aggregate_starttime, aes(x=n , fill = as.factor(StartDay))) + geom_density()

## based on weather types
ggplot(aggregate_starttime_day_weatherHoliday, aes(x=n, fill = as.factor(Types))) + geom_density()
ggplot(aggregate_starttime_day_weatherHoliday, aes(x=n, fill = as.factor(Holiday))) + geom_density()

### Histogram

par(mfrow=c(4,2))
par(mar = rep(2, 4))
hist(aggregate_starttime_day_weatherHoliday$Types)
hist(aggregate_starttime_day_weatherHoliday$Weekend)
hist(aggregate_starttime_day_weatherHoliday$Holiday)
hist(aggregate_starttime_day_weatherHoliday$Mean.Temp)
hist(aggregate_starttime_day_weatherHoliday$Mean.Wind)
hist(aggregate_starttime_day_weatherHoliday$Mean.Visib)
hist(aggregate_starttime_day_weatherHoliday$Mean.Visib)


# ggplot(starttime_holiday, aes(x=StartHour, y=n, color = Holiday)) + geom_point()
# 
# ggplot(starttime_holiday, aes(x=StartMonth, y=n)) + geom_point()
# 
# ggplot(starttime_holiday, aes(x=StartMonth)) + geom_line(aes(y= n, color = 'red'))







### References
# https://github.com/artem-fedosov/bike-sharing-demand/blob/master/read_data.R
# https://www.analyticsvidhya.com/blog/2015/06/solution-kaggle-competition-bike-sharing-demand/

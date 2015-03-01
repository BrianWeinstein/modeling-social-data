#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
sed 1d 201402-citibike-tripdata.csv | cut -d, -f4 | sort | uniq | wc -l

# count the number of unique bikes
sed 1d 201402-citibike-tripdata.csv | cut -d, -f12 | sort | uniq | wc -l

# extract all of the trip start times
sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2

# count the number of trips per day
sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2 | cut -c 2-11 | sort | uniq -c

# find the day with the most rides
sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2 | cut -c 1-11 | sort | uniq -c | sort -nr | head -n1 | cut -d'"' -f2

# find the day with the fewest rides
sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2 | cut -c 1-11 | sort | uniq -c | sort -n | head -n1 | cut -d'"' -f2

# find the id of the bike with the most rides
sed 1d 201402-citibike-tripdata.csv |  cut -d, -f12 | sort | uniq -c | sort -nr | head -n1 | cut -d'"' -f2

# count the number of riders by gender and birth year
sed 1d 201402-citibike-tripdata.csv | cut -d, -f15,14 | sort | uniq -c # this really calculates the number of *trips* (not riders) by gender and birth year

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)
sed 1d 201402-citibike-tripdata.csv | cut -d, -f5 | grep '[0-9].*&.*[0-9]' | wc -l

# compute the average trip duration
awk -F'"' '{tripdurationSum += $2} END {print tripdurationSum / NR}' 201402-citibike-tripdata.csv

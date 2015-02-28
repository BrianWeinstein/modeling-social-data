#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations

sed 1d 201402-citibike-tripdata.csv | cut -d, -f4 | sort | uniq | wc -l # count the unique start station ids
sed 1d 201402-citibike-tripdata.csv | cut -d, -f8 | sort | uniq | wc -l # also check the end station ids to verify

# count the number of unique bikes

sed 1d 201402-citibike-tripdata.csv | cut -d, -f12 | sort | uniq | wc -l

# extract all of the trip start times

sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2

# count the number of trips per day

sed 1d 201402-citibike-tripdata.csv |  cut -d, -f2 | cut -c 1-11 | sort | uniq -c

# find the day with the most rides

# find the day with the fewest rides

# find the id of the bike with the most rides

# count the number of riders by gender and birth year

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)

# compute the average trip duraction

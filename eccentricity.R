library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)

# Import the ratings.csv file
raw.ratings <- read.csv(file=file.choose(), 
                        header=FALSE, 
                        col.names=c("userID", "movieID", "rating", "timestamp"),
                        sep=",")
ratings <- raw.ratings



# Calculate movie popularity. The more ratings a movie has, the more "popular" it is (independent of the ratings themselves).
movie.info <- ratings %>% group_by(movieID) %>% summarize(ranking=n()) %>% arrange(-ranking)
movie.info$ranking <- 1:nrow(movie.info)



# Join movie rank value to ratings table
ratings <- left_join(x=ratings, y=movie.info, by="movieID") %>% arrange(userID, ranking)



# Calculate the number of movies each user has rated, the ranking of their least popular movie, and the ranking of their 90th% least popular movie
user.info <- 
  ratings %>% 
  group_by(userID) %>% 
  summarize(moviesRated=n(), highestRank=max(ranking), ninetyRank=ranking[ceiling(moviesRated*0.9)])



# Count the number of users at each highestRank and ninetyRank
user.counts.highest <- user.info %>% group_by(highestRank) %>% summarize(numUsersHighest=n())
user.counts.ninety <- user.info %>% group_by(ninetyRank) %>% summarize(numUsersNinety=n())



# Join the user.count.highest and user.counts.ninety tables
user.counts <- data.frame(ranking=unique(movie.info$ranking))
user.counts <- merge(x=user.counts, y=user.counts.highest, by.x="ranking", by.y="highestRank", all.x=T)
user.counts <- merge(x=user.counts, y=user.counts.ninety, by.x="ranking", by.y="ninetyRank", all.x=T)

rm(user.counts.highest, user.counts.ninety)

# Convert NAs to 0
user.counts$numUsersHighest[is.na(user.counts$numUsersHighest)] <- 0
user.counts$numUsersNinety[is.na(user.counts$numUsersNinety)] <- 0



# Calculate cumulative user counts for each column and divide by the sum of each column
user.counts$satisfiedUsersHighest <- cumsum(user.counts$numUsersHighest)/nrow(user.info)
user.counts$satisfiedUsersNinety <- cumsum(user.counts$numUsersNinety)/nrow(user.info)

# Melt the user.counts table
satisfied.pct <- 
  select(user.counts, ranking, satisfiedUsersHighest, satisfiedUsersNinety) %>% 
  melt(id.vars="ranking", measure.vars=c("satisfiedUsersNinety", "satisfiedUsersHighest"), value.name="satisfiedPct")

# Plot
ggplot(data=satisfied.pct) + 
  geom_line(aes(x=ranking, y=satisfiedPct, group=variable, color=variable)) + 
  scale_x_continuous(labels=comma) +
  scale_y_continuous(labels=percent) +
  xlab("Inventory Size (Movie Rank)") + ylab("Percent of Users Satisfied") + ggtitle("Percent of Users Satisfied by Inventory Size") + 
  theme(legend.position=c(0.8,0.2)) + 
  labs(color="Percent Satisfaction") + 
  scale_color_hue(labels=c("90%","100%"))






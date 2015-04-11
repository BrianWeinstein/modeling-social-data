library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(ggplot2)

# read business and world articles into one data frame #######################################
business <- read.table('business.tsv', header=T)
world <- read.table('world.tsv', header=T)
articles <- rbind(business, world) # Documents 1-1000 are 'business', 1001-2000 are 'world'
rm(business, world)


# create a Corpus from the article snippets ##################################################
corpus <- Corpus(VectorSource(articles$snippet))



# remove punctuation and numbers #############################################################
corpus <- tm_map(corpus, removePunctuation) # Remove all punctuation
corpus <- tm_map(corpus, removeNumbers) # Remove all numbers



# create a DocumentTermMatrix from the snippet Corpus ########################################
dtm <- DocumentTermMatrix(corpus)



# convert the DocumentTermMatrix to a sparseMatrix, required by cv.glmnet  ###################
# helper function
dtm_to_sparse <- function(dtm) {
 sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)
}

dtmSM <- dtm_to_sparse(dtm)

# create a train / test split  ###############################################################
set.seed(12)
ndx <- sample(1:nrow(dtmSM), round(nrow(dtmSM)*0.8), replace=F)
dtmSM.train <- dtmSM[ndx, ]
dtmSM.test <- dtmSM[-ndx, ]
rm(ndx)



# cross-validate logistic regression with cv.glmnet, measuring auc  ##########################

# Create response vectors. 1=business, 0=world
response.train <- as.numeric(as.numeric(rownames(dtmSM.train)) < 1000)
response.test <- as.numeric(as.numeric(rownames(dtmSM.test)) < 1000)

# Cross-validated logistic regression model, minimizing AUC
cvfit <- cv.glmnet(dtmSM.train, response.train, family="binomial", type.measure="auc")

cvfit$lambda.min
coef(cvfit, s = "lambda.min")

plot(cvfit)

# evaluate performance for the best-fit model

View(predict(cvfit, newx = dtmSM.test, s = "lambda.min", type="class"))



# plot ROC curve and output accuracy and AUC

# extract coefficients for words with non-zero weight
# helper function
get_informative_words <- function(crossval) {
  coefs <- coef(crossval, s="lambda.min")
  coefs <- as.data.frame(as.matrix(coefs))
  names(coefs) <- "weight"
  coefs$word <- row.names(coefs)
  row.names(coefs) <- NULL
  subset(coefs, weight != 0)
}

# show weights on words with top 10 weights for business

# show weights on words with top 10 weights for world

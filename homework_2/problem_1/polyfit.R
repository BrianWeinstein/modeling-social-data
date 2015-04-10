library(ggplot2)



# read data ####################################################################
data <- read.table('polyfit.tsv', header=T)



# split into train / test data #################################################
set.seed(12)
ndx <- sample(1:nrow(data), round(nrow(data)/2), replace=F)
data.train <- data[ndx, ]
data.test <- data[-ndx, ]
rm(ndx)



# fit a model and compute train / test error for each degree ###################

# Define a RMSE function
rmse <- function(data, predictions){
  sqrt(mean((data-predictions)^2))
}

# Measure the RMSE for fits of increasing degree
fit <- data.frame()
for (degree in 1:17) {
  model <- lm(y ~ poly(x, degree), data=data.train)
  fit.train <- rmse(data.train$y, predict(model, data.train))
  fit.test <- rmse(data.test$y, predict(model, data.test)) 
  fit <- rbind(fit, data.frame(degree=degree, train=fit.train, test=fit.test))
}
rm(fit.train, fit.test)



# select best model ############################################################
best.test <- fit[grep(min(fit$test), fit$test), ]
best.test
optimal.degree <- best.test$degree
model <- lm(y ~ poly(x, optimal.degree), data=data.train)



# plot fit for best model ######################################################

# RMSE vs degree
fitPlotData <- data.frame(degree=rep(1:nrow(fit), 2),
                   fit=c(rep("train", nrow(fit)), rep("test", nrow(fit))),
                   test=c(fit$train, fit$test))
ggplot(data=fitPlotData, aes(x=degree, y=test, group=fit, color=fit, shape=fit)) + 
  geom_line() + 
  geom_point() + 
  geom_vline(xintercept=optimal.degree, color="gray", linetype="dashed") + 
  xlab("Degree") + ylab("RMSE") + ggtitle("RMSE vs Degree") + 
  theme_bw() + theme(legend.position=c(0.8,0.8)) +
  labs(group="", color="", shape="")
ggsave(filename='rmse_vs_degree.pdf', width=8, height=4)

# Plot of best fit
ggplot(data=data, aes(x=x, y=y)) + 
  geom_point() + 
  stat_smooth(formula=y ~ poly(x, optimal.degree), method="lm", se=F, size=1.5) + 
  xlab("x") + ylab("y") + ggtitle("Best Fit") + 
  theme_bw()
ggsave(filename='best_fit.pdf', width=8, height=4)



# report coefficients for best model ###########################################
model$coefficients



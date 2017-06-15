
###### Data Carpentry 6/13/16
####Session  Overview
# Lessons
## 1. if else (Stephen)
## 2. writing loops (Stephen)
## 3. writing functions (Lynn)

rm(list = ls(all=TRUE))


###Loading the Data
svy <- read.csv("svy_complete.csv", header=TRUE)
str(svy) 

##Loading the libraries
library(ggplot2)
library(dplyr)

################1. If Else Statements----------------------

###General syntax:
###if (test expression 1) {
#statement1
##} else if (test expression 2){
##statement2
##}

##If  statements operate on length-one logical vectors
##Some uses:
##Can be used to give a message if a certain condition is satisfied
##Can also be used to create new variables

#Generate 1 random number from Uniform[-10,10], call it x.
#Write a if statement to determine if it is positive 
x<-runif(1, min=-10, max=10) 
if(x>0){
  print("Positive number")
  }

##We could modify this to include an "else" statement for when x is not positive

x<-runif(1, min=-10, max=10) 

if(x>0){
  print("Positive number")
}else if (x<0) {
    print("Negative number")
  }

#Note that the spacing above is intentional 
##How could we modify the code above if x is zero?
x<-0
if(x>0){
  print("Positive number")
}else if (x<0) {
  print("Negative number")
} else if (x==0){ 
  print("Zero")}


##Using And, &
#Determine if the first weight value is between Q1 and Q3 or  outside the middle 50%
summary(svy$weight)
x<-svy$weight[1]
x
if(x>20 &x<47){ 
  z<-1
} else {
  z<-0}
z


##Notice, we could nest functions in the if statement:
quantile(svy$weight, probs=0.25) 
quantile(svy$weight, probs=0.75) 

if(x>quantile(svy$weight, probs=0.25)  &x<quantile(svy$weight, probs=0.75) ){ 
  z<-1
} else {
  z<-0}
z


##Using Or, |
#The same statement could be written using OR
if(x<20|x> 47){ 
  y<-0
} else {
  y<-1}
x
y

##Challenge: Write an if statement to determine if the first observation has a value of 
#weight less than first quartile for weight AND 
#a value of hindfoot_length less than the first quartile for hindfoot_length.
quantile(svy$weight, probs=0.25) 
quantile(svy$hindfoot_length, probs=0.25)
x<-svy$weight[1]
y<-svy$hindfoot_length[1]
x
y

if(x<quantile(svy$weight, probs=0.25) &y<quantile(svy$hindfoot_length, probs=0.25)){ 
  z<-1
} else {
  z<-0}
z


##When cleaning the data, it may be useful to make sure that no values are above or below a certian limit
##This can be achieved by using an if statement with the any() function

###Lets write a statement that will detect if there is an lower outlier
##A lower outlier is defined by any value that is less than Q1-1.5*(Q3-Q1) 
summary(svy$weight)


if(any(svy$weight<20-1.5*(47-20))){
  print("there is a lower outlier")
}else {
  print("there is no lower outlier")
}


#How to modify the code to detect an upper outlier?
#A lower value is  greater than Q3+1.5*(Q3-Q1)

if(any(svy$weight>47+1.5*(47-20))){
  print("there is an upper outlier")
}else {
  print("there is no upper outlier")
}

#Similarly, the all() command could be useful in the cleaning process
#For instance, we would expect that weight should always be positive

if(all(svy$weight>=0)){
  print("all values are non-negative")
} else { print("there is a negative value")
  }


###############2. Loops-----------------------
##The if else statements covered above are limited by the fact that it can only handle a vector of length one
##We can use loops to apply the decisions to vector of any length
##General syntax:
##for (i in 1:n){
#(statement)
#}

###A. Write a loop that centers the year variable (Using loops)
##First we will initalize a column into our dataset, by setting all the values equal to NA
svy$year_c<-NA
##The loop will go through each row and perform the same action. To determine the number of rows, 
#we can use the dim function or nrow
nrow(svy)

for (i in 1:nrow(svy)){
  (svy$year_c[i]<-svy$year[i]-mean(svy$year))
}
head(svy)
##Notice, we could have done this without a loop, which is more efficient: 
svy$year_c2<-svy$year-mean(svy$year)

###B. Write a loop that dichtomizes weight. (Using for loops and if else statement)
###Any weight less than the median will be coded as 0; 
#any weight greater than or equal to the median coded as 1
median(svy$weight)
##First we will initalize a vector, in which we will store the results
svy$weight_bin<-NA

for (i in 1: nrow(svy)){
  if (svy$weight[i] <median(svy$weight)){svy$weight_bin[i]<-0}
  else if (svy$weight[i] >=median(svy$weight)){svy$weight_bin[i]<-1}
  print(i)
}
head(svy)

#Challenge: Write a loop that produces a binary variable for weight
## give a 1 if the observation is an UPPER outlier, give a 0 if not. 
#Upper Outlier is a value greater than Q3+1.5*(Q3-Q1)
summary(svy$weight)
svy$weight_Uoutlier<-NA

for (i in 1: nrow(svy)){
  if (svy$weight[i] >47+1.5*(47-20)){svy$weight_Uoutlier[i]<-1}
  else {svy$weight_Uoutlier[i]<-0}
  print(i)
}

###You could then filter the non-outliers out
svy_noUoutliers<-svy %>%filter(weight_Uoutlier==0) 

###C.Write a loop that estimates the effect of weight on hindfoot_length for each species

##Let's run an example 
lm1.1<-lm(hindfoot_length~weight, data=subset(svy, species_id=="DM"))
##How do we extract the coefficients?
lm1.1$coefficients
##But how do we get standard errors and p-values?  Through the summary command.
summary1.1<-summary(lm1.1)
summary1.1
summary1.1$coefficients
summary1.1$coefficients[2,1] #estimate
summary1.1$coefficients[2,4]#p-value


#use the expand.grid function to create a new dataset to store the results in
results1<-expand.grid(species_id=unique(svy$species_id))
View(results1)

##We will run the loop over the species_id
nm<-levels(svy$species_id)
nm
nm[1]

for (i in 1:length(nm)){
  model<-summary(lm(hindfoot_length~ weight, data=subset(svy, species_id==nm[i])))
  results1$slope[i]<-model$coefficients[2,1]
  results1$pvalue[i]<-model$coefficients[2,4]
  print(i)
}
View(results1)


#Challenge. Modify the loop in example  to now include the standard error and t-estimate
results1<-expand.grid(species_id=unique(svy$species_id))
for (i in 1:length(nm)){
  model<-summary(lm(hindfoot_length~ weight, data=subset(svy, species_id==nm[i])))
  results1$slope[i]<-model$coefficients[2,1]
  results1$se[i]<-model$coefficients[2,2]
  results1$t[i]<-model$coefficients[2,3]
  results1$pvalue[i]<-model$coefficients[2,4]
  print(i)
}
View(results1)

## If you needed to add df, example:df.residual(lm(hindfoot_length~ weight, data=subset(svy, species_id==nm[1])))

####D. Write a loop that makes a scatter plot for each of the linear models run above----
###First, let us run one for one species

ggplot(subset(svy, species_id=="DM"), aes(x=weight, y=hindfoot_length))+geom_point()
nm<-levels(svy$species_id)
nm
ggplot(subset(svy, species_id==nm[1]), aes(x=weight, y=hindfoot_length))+geom_point()

for (i in 1:length(nm)){
  scatterplots<-ggplot(subset(svy, species_id==nm[i]), aes(x=weight, y=hindfoot_length))+geom_point()
  plot(scatterplots)
  print(i)
}

###But how do we know which species each plot is for? 
##We could add a title using ggtitle
for (i in 1:length(nm)){
  scatterplots<-ggplot(subset(svy, species_id==nm[i]), aes(x=weight, y=hindfoot_length))+ geom_point()+
    ggtitle(nm[i])
  plot(scatterplots)
  print(i)
}


##Now How do we save these images?
##we can use the ggsave option, which will save the files into the working directory
for (i in 1:length(nm)){
  scatterplots<- ggplot(subset(svy, species_id==nm[i]), aes(x=weight, y=hindfoot_length))+geom_point()+
    ggtitle(nm[i])
  ggsave(scatterplots,filename=paste(nm[i],".png",sep=""))
  print(i)
}


####### EXTRA Loop Challenges--------
#1. Modify the loop in example 2B by using the median weight within a species, instead of the overall median
species_med<-svy %>% group_by(species_id) %>%summarise(median=median(weight))
species_med
median(svy$weight[svy$species_id=="DM"])
median(svy$weight[svy$species_id==svy$species_id[1]])

##This is so not efficient... 
for (i in 1: nrow(svy)){
  median<-median(svy$weight[svy$species_id==svy$species_id[i]])
  if (svy$weight[i] <median){svy$weight_bin[i]<-0}
  else if (svy$weight[i] >=median){svy$weight_bin[i]<-1}
  print(i)
}



##2. Write a loop that estimates the effect of weight in predicting hindfoot length for every speices by gender combination
##Store the p-value and estimate (use which)
nm<-levels(svy$species_id)
s<-levels(svy$sex)
results2<-expand.grid(species_id=unique(svy$species_id), sex=unique(svy$sex))
results2$b<-NA
results2$pvalue<-NA
View(results2)
for (i in 1:length(nm)){
  for (j in 1:length(s)){
    model<-summary(lm(hindfoot_length~ weight, data=subset(svy, species_id==nm[i]&sex==s[j])))
    results2$pvalue[which(results2$species_id==nm[i]&results2$sex==s[j])]<-model$coefficients[2,4]
    results2$b[which(results2$species_id==nm[i]&results2$sex==s[j])]<-model$coefficients[2,1]
    print(i)
    print(j)
  }
}
View(results2)






##############3. Functions---------------------
# why use functions?
# R is already full of functions, but the one you need might not be exist
#Writing your own functions will allow you to easily execute repetitive tasks
# ... more reasons ...


# Example 1. ----
summary(svy$weight)
var(svy$weight)
sd(svy$weight)
sd(svy$weight)/sqrt(30463) # better to generalize this based on the data
n <- length(svy$weight)
sd(svy$weight)/sqrt(n)

# Let's write a function to compute the SEM!
# Structure of a function is as follow:
#function_name <- function(arg1, arg2, ...){
#  statements
#}

sem <- function(x){
  n = length(x)
  sd(x)/sqrt(n)
}
sem(svy$weight) # output of function is last expression evaluated
# Note: Arguments in function can be specified by name or position.
sem(x=svy$weight) 
# Not an issue for functions with a single argument (or maybe two); otherwise should use matching by name

sem(svy$hindfoot_length)

# can view components of your function
sem
formals(sem)
body(sem)
environment(sem) # determines where the function looks for variables

# What happens if we supply an x value that is not numeric?
sem(svy$sex)

# require x be numeric
sem <- function(x){
  stopifnot(is.numeric(x))
  n = length(x)
  sd(x)/sqrt(n)
}
sem(svy$weight)
sem(svy$sex)


# Example 2. ----
# Create a function which computes set of summary statistics of interest
summstats <- function(x){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x)
  median = median(x)
  mean = mean(x)
  max = max(x)
  sd = sd(x)
  sem = sd/sqrt(n)
  cbind(n, min, median, mean, max, sd, sem)
}
summstats(svy$weight)


# Challenge 1: ----
# Update the summstats function to also produce a histogram (give the function a new name)
stats_plot <- function(x){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x)
  median = median(x)
  mean = mean(x)
  max = max(x)
  sd = sd(x)
  sem = sd/sqrt(n)
  plot(hist(x))
  cbind(n, min, median, mean, max, sd, sem)
}
stats_plot(svy$weight)
 


#Write with ggplot
stats_plot <- function(x, data){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x)
  median = median(x)
  mean = mean(x)
  max = max(x)
  sd = sd(x)
  sem = sd/sqrt(n)
  hist<-ggplot(data, aes(x=x, fill=x), environment = environment())+geom_histogram()
  plot(hist)
  print(cbind.data.frame(n, n1, min, median, mean, max, sd, sem))
}
stats_plot(svy$weight, data=svy)

# Rewrite function to make histogram optional, but make producing the histogram the default
stats_plot <- function(x, plot=TRUE){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x)
  median = median(x)
  mean = mean(x)
  max = max(x)
  sd = sd(x)
  sem = sd/sqrt(n)
  if (plot==TRUE){
    plot(hist(x))
  }
  cbind(n, min, median, mean, max, sd, sem)
}
stats_plot(svy$weight)
stats_plot(svy$hindfoot_length, plot=FALSE)


# Challenge 2: ----
# Write a function that will create summary statistics by a grouping variable (e.g. specied_id, sex)
#Hint: In the function, create a variable that contains all the levels of the grouping variable.
##Then run a loop so that for each level you obtain the summary stats
grouplist = levels(svy$species_id)
grouplist[1]
str(grouplist[1])

summBYgroup <- function(x, group){
  grouplist = levels(group)
  for (i in 1:length(grouplist)){
    name = grouplist[i]
    groupx = x[group==name]
    n = length(groupx)
    sem = sd(groupx)/sqrt(n)
    min = min(groupx)
    median = median(groupx)
    mean = mean(groupx)
    max = max(groupx)
    sd = sd(groupx)
   print(cbind(name, n, min, median, mean, max, sd, sem)) # have to print it since not last expression
#    print(cbind.data.frame(name, n, min, median, mean, max, sd, sem)) # allows different variable types
  }
}
summBYgroup(svy$weight, svy$species_id)  
summBYgroup(svy$weight, svy$sex) 

# or could chain the functions
summBYgroup <- function(x, group){
  grouplist = levels(group)
  for (i in 1:length(grouplist)){
    species = grouplist[i]
    groupx = x[group==species]
    print(cbind.data.frame(species, summstats(groupx)))
  }
}

summBYgroup(svy$weight, svy$species_id) # matching by position
summBYgroup(svy$species_id, svy$weight) # have to be careful when using matching by position!
summBYgroup(group=svy$species_id, x=svy$weight) # matching by name


# Bonues challenge ----
# Dataset we have been using doesn't have any missing values. If we create some missing values
# how will this impact the function we have written?
svy_na <- svy
svy_na$weight[1:3] <- NA 
summstats(svy_na$weight)

# Rewrite the summstats function to ignore missing values in calculations
summstats <- function(x){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x, na.rm=TRUE)
  median = median(x, na.rm=TRUE)
  mean = mean(x, na.rm=TRUE)
  max = max(x, na.rm=TRUE)
  sd = sd(x, na.rm=TRUE)
  sem = sd/sqrt(n)
  cbind(n, min, median, mean, max, sd, sem)
}
summstats(svy_na$weight)

# or we could make it option to ignore missing values (but the default)
summstats <- function(x, rem=TRUE){
  stopifnot(is.numeric(x))
  n = length(x)
  min = min(x, na.rm=rem)
  median = median(x, na.rm=rem)
  mean = mean(x, na.rm=rem)
  max = max(x, na.rm=rem)
  sd = sd(x, na.rm=rem)
  sem = sd/sqrt(n)
  cbind(n, min, median, mean, max, sd, sem)
}
summstats(svy_na$weight)
summstats(svy_na$weight, rem=FALSE)


# If you have a few functions that you want to use repeatedly, you can put them in there own 
# R script file and just "source" that file at the top of your analysis file.
source("AuxiliaryFunctions.R")

# May also be helpful to create formal documentation for functions in some cases, especially 
# if you plan to share the functions with others.

# Other useful things:
# ... is called an ellipsis
sem(svy$weight, svy$sex)

sem2 <- function(x, ...){
  stopifnot(is.numeric(x))
  n = length(x)
  sd(x)/sqrt(n)
}
sem2(svy$weight, svy$sex) # ellipsis allows extra arguments to be ignored


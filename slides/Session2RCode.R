
# Data Carpentry 6/14/17
# Session 2 Overview
# Lessons
## 1. Importing data and working with data.frames
## 2. Manipulating data with the dplyr package
## 3. Data visualization with the ggplot2 package


#https://github.com/datacarpentry/ecology-workshop/blob/master/data.md
#https://www.cscu.cornell.edu/workshops/ggplot.php

rm(list = ls(all=TRUE))

# Lesson 1 - Importing data and working with data.frames ---------------------------------------------
svydat <-  read.csv("Summer 2017/Data/surveys.csv", header=TRUE) 
#View(svydat)
head(svydat)
dim(svydat)
nrow(svydat)
ncol(svydat)
str(svydat) # character variables are automatically coerced to be factors; need to change others

# subsetting data by [rows, cols]
svydat[1:10, 1:4]
svydat[1:10, ]
svydat[1:10, c("record_id", "plot_id", "species_id")]

# working with a variable in the dataframe
svydat$hindfoot_length
svydat$hindfoot_length[1:10] # there are some missing values here; which plots are they from?

svydat$plot_id[is.na(svydat$hindfoot_length)]
table(svydat$plot_id[is.na(svydat$hindfoot_length)])
table(svydat$plot_id[!is.na(svydat$hindfoot_length)])

# force categorical variables to factors
svydat$record_id <- as.factor(svydat$record_id) # <- versus =
svydat$plot_id <- as.factor(svydat$plot_id)
str(svydat)
summary(svydat)

table(svydat$plot_id)
levels(svydat$plot_id)

table(svydat$species_id)
levels(svydat$species_id)

# change "" values to NA
svydat$species_id[svydat$species_id==""] <- NA
table(svydat$species_id)
table(svydat$species_id, useNA="ifany")
svydat$species_id <- droplevels(svydat$species_id)
table(svydat$species_id, useNA="ifany")

levels(svydat$sex)
svydat$sex[svydat$sex==""] <- NA
svydat$sex <- droplevels(svydat$sex)
levels(svydat$sex)
table(svydat$sex, useNA="ifany")

# could have saved ourselves a bunch of time had we known there were "" values that should be NA's:
svydat2 <-  read.csv("Summer 2017/Data/surveys.csv", na.strings="")
summary(svydat2)


# Lesson 2 - Managing and analyzing data with the dplyr (and tidyr) packages --------------------------------------------
# Why should we use dplyr?
## Provides easy tools for the most common data manipulation taaks
## Code is intuitive 
## Constrained number of options that correspond to the most common data manipulations
## Fast
install.packages("dplyr")
library(dplyr) # masks a few base R functions

# create a local data.frame (optional)
svy <- tbl_df(svydat)
svydat
svy # shows only the first 10 rows and as many variables as will fit on the screen
    # shows dimension and variable types
    # can use either svydat or svy in dplyr functions, we will use svy since it prints so nicely
    # svy will print more nicely even if we're not using dplyr functions
print(svy, n=20) # to see more rows

# 5 main verbs/functions in dplyr: filter, select, arrange, mutate, summarise (+ group_by)
## FILTER - return rows with matching conditions -------------
## return data from January 1983
# base R:
svy[svy$year==1983 & svy$month==1, ]

# dplyr:
filter(svy, year==1983, month==1) 
filter(svy, year==1983 & month==1) # can use , or &; doesn't change svy dataframe

# to create a new dataframe
jan1983 <- filter(svy, year==1983 & month==1) # look at data

## return data for species DS from January 1983
# base R:
svy[svy$year==1983 & svy$month==1 & svy$species_id=="DS", ] 
print(svy[svy$year==1983 & svy$month==1 & svy$species_id=="DS", ], n=22) 
  # what is the deal with these NA's! there are no missing year or month values
svy$species_id[svy$year==1983 & svy$month==1] # 4 obs with missing species_id in January 1983; need to remove
svy[svy$year==1983 & svy$month==1 & svy$species_id=="DS" & !is.na(svy$species_id),]

# dplyr:
filter(svy, year==1983, month==1, species_id=="DS") # automatically excludes obs with missing species_id

# can also use |, and %in%
# data for species UP and UR
filter(svy, species_id=="UP" | species_id=="UR")
filter(svy, species_id %in% c("UP","UR"))


# Challenge: Create a data.frame containing obs for species PF where weight is not missing.
# How many males and females are there?
pf_wts <- filter(svydat, species_id=="PF", !is.na(weight))
table(pf_wts$sex)


## SELECT - pick columns by name -------------
# base R:
svy[, c("species_id", "sex", "hindfoot_length", "weight")]

# dplyr:
select(svy, species_id, sex, hindfoot_length, weight) # very similar to filter command

select(svy, contains("id"), sex:weight) # also can use "starts_with", "ends_with", "matches"


# "chaining" or "pipes" - not a main verb, but can help you avoid nesting functions
# return year, species_id, weight and then filter weights less than 5
# can use two steps:
species_wt <- select(svy, year, species_id, weight)
filter(species_wt, weight<5) # could filter and then select
  # have to define useless intermediate data.frame

# or nest functions:
filter(select(svy, year, species_id, weight), weight<5)
  # code isn't that hard to read, but does take a bit of thought

# or use pipes to take the output of one function and then send it directly to the next
# comes from magrittr package (installed with dplyr)
# dplyr/magrittr
svy %>%
  select(year, species_id, weight) %>%
  filter(weight < 5)
  # read %>% as "then"
  # don't have to repeat dataframe name
  # increases readability when there are multiple nested functions
  # doesn't actually have to go on 3 lines

# can use it to create a new dataframe:
small_sp <- svy %>%
  select(year, species_id, weight) %>%
  filter(weight < 5)


# Challenge: Create a new data.frame that contains year, species_id, and weight for  
# observations from 2000.
# What is the mean weight?
sp2000 <- svy %>%
  select(year, species_id, weight) %>%   # could change order of operations here too
  filter(year==2000)
mean(sp2000$weight, na.rm=TRUE)

# or
sp2000 <- svy %>%
  select(year, species_id, weight) %>%   
  filter(year==2000, !is.na(weight))
mean(sp2000$weight)


## ARRANGE - reorder rows -------------
# return year, month, sex, hindfoot_length sorted by year and month 
# can be a pain in base R: svy[order(svy$year, svy$month), c("year", "month", "sex", "hindfoot_length")]
svy %>%
  select(year, month, sex, hindfoot_length) %>%
  arrange(year, month)

svy %>%
  select(year, month, sex, hindfoot_length) %>%
  arrange(desc(year), month)

# can save
svy_sort <- svy %>%
  select(year, month, sex, hindfoot_length) %>%
  arrange(desc(year), month)


## MUTATE - adds new variables  ---------
# create variable for ratio of weight/hindfoot_length
# base R:
svy$wl_ratio1 = svy$weight/svy$hindfoot_length

# dplyr:
mutate(svy, wl_ratio2 = weight/hindfoot_length)  # just prints the new variable
svy %>% mutate(wl_ratio2 = weight/hindfoot_length) # using pipes
svy <- svy %>% mutate(wl_ratio2 = weight/hindfoot_length)

# can remove variables with mutate
svy <- svy %>% mutate(wl_ratio1=NULL, wl_ratio2=NULL) 


## SUMMARISE - summarize variables --------------
# useful in conjuction with group_by
# calculate average weight for each species
# base R:
tapply(svy$weight, svy$species_id, mean)
tapply(svy$weight, svy$species_id, mean, na.rm=TRUE)


# dplyr:
svy %>%
  group_by(species_id) %>%
  summarise(mean(weight, na.rm=TRUE))
svy %>%
  filter(!is.na(weight)) %>%
  group_by(species_id) %>%
  summarise(mean(weight))  # drops with species with no weight values
# now save it as a data.frame and add variable name
sp_avg_wts <- svy %>%
  filter(!is.na(weight)) %>%
  group_by(species_id) %>%
  summarise(avg_wt = mean(weight))

# count number of observations per month 
svy %>%
  group_by(month) %>%
  summarise(count=n())
# or use tally command
svy %>%
  group_by(month) %>%
  tally
# now save it in a data.frame
monthly_counts <- svy %>%
  group_by(month) %>%
  tally


# Challenge: For each species, calculate the mean weight for each sex and determine the 
# sample size (count) used to compute that mean (hint: don't use tally).
svy %>%
  filter(!is.na(weight)) %>%
  group_by(species_id, sex) %>%
  summarise(count=n(), mean_wt=mean(weight)) 


# Why would we use tidyr?
## To reshape your data for plotting or analysis purposes
## Wide to long format, long to wide format
install.packages("tidyr")
library(tidyr)

# create dataframe with mean weight for each sex by year 
avgwt <- svy %>%
  group_by(year, sex) %>%
  filter(!is.na(sex), !is.na(weight)) %>%
  summarise(avg_wt=mean(weight)) 

# create wide dataset with a single row for each year and separate columns for each gender
avgwt_wide <- spread(avgwt, sex, avg_wt) # data, variable to spread on, data to spread

# change it back to long format
avgwt_long <- gather(avgwt_wide, sex, avg_wt, F:M) # data, name of new group, name of new measurment, data to gather


# dplyr & tidyr cheatsheet:
# https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf


# Create output datafile to use in next section: -------------------
# Remove obs with any missing values (species_id, weight, hindfoot_lenth, or sex):
svy_complete <- svy %>%
  filter(!is.na(species_id), !is.na(weight), !is.na(hindfoot_length), !is.na(sex))    

svy_complete <- svy %>%
  drop_na()

# Remove data for rare species (those with fewer than 50 obs):
# create a list of species IDs for non-rare species
species_nonrare <- svy_complete %>%
  group_by(species_id) %>%
  summarise(count=n()) %>%
  filter(count >= 50) %>%
  select(species_id)

# Keep data for most common species:
svy_complete <- svy_complete %>%
  filter(species_id %in% species_nonrare$species_id) 

dim(svy_complete) # should have 30463 rows and 9 variables

write.csv(svy_complete, file="Summer 2017/Data/svy_complete.csv", row.names=FALSE)


# Lesson 3 - Data visualization with the ggplot2 package -----------------------------------------

rm(list = ls(all=TRUE))

# Why use ggplot2?
## Customizable, pretty graphics
## Based on "grammar of graphics" (describing components of a graph, easy to use once you know the basics)
# How does it work?
## ggplot function initializes the basic graph structure, then elements are addded to the graph
## aes (aesthetics) - maps variables to the plot
## geom - adds geometric objects to the plot (geom_point, geom_line, geom_boxplot, geom_smooth)
## scales - to modify axes and labels
## facets - plot panels 

library(dplyr)
library(ggplot2)

svy <- read.csv("Summer 2016/Data/svy_complete.csv", header=TRUE)


# Three examples: scatterplot, side-by-side boxplots, longitudinal (time series) plot

# Scatterplot of hindfoot lenght versus weight --------------
ggplot(data = svy)
ggplot(data = svy, aes(x = weight, y = hindfoot_length))
ggplot(data = svy, aes(x = weight, y = hindfoot_length)) +
  geom_point() # anything set up in aes can be seen by the geom layers, or these can be set up 
               # separately in the geom function
# note: can go to next line but + must be on prior line

# can also create a plot object
svy_plot <- ggplot(data = svy, aes(x = weight, y = hindfoot_length))

# and then add to it and render it later
svy_plot + geom_point()  # I'm not going to do this so my code doesn't run off the screen

# can customize at each level
ggplot(data = svy, aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.5) # make points transparent; change to 0.5 and 0.1

# change color
ggplot(data = svy, aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1, color = "blue") 

# color by species
ggplot(data = svy, aes(x = weight, y = hindfoot_length)) +
  geom_point(alpha = 0.1, aes(color=species_id))  

# could have also put the color in the ggplot function aes function
ggplot(data = svy, aes(x = weight, y = hindfoot_length, color=species_id)) +
  geom_point(alpha = 0.1)

# add axis labels and change name on legend
ggplot(data = svy, aes(x = weight, y = hindfoot_length, color=species_id)) +
  geom_point(alpha = 0.1) +
  xlab("Weight (g)") +
  ylab("Hindfoot Length (mm)") +
  labs(color="Species")


# Challenge: Create a scatterplot of hindfoot lenght versus weight color-coded by year;
# add appropriate axis labels.
ggplot(data = svy, aes(x = weight, y = hindfoot_length, color=year)) +
  geom_point(alpha = 0.1) +
  xlab("Weight (g)") +
  ylab("Hindfoot Length (mm)") +
  labs(color="Year") 

ggplot(data = svy, aes(x = weight, y = hindfoot_length, color=as.factor(year))) +
  geom_point(alpha = 0.1) +
  xlab("Weight (g)") +
  ylab("Hindfoot Length (mm)") +
  labs(color="Year")
# are animals getting smaller?! no, species captured is changing over time


# Boxplots of hindfoot length by species ----------------------
ggplot(data = svy, aes(x = species_id, y = hindfoot_length)) +
  geom_boxplot()

# add jitter to data points
ggplot(data = svy, aes(x = species_id, y = hindfoot_length)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.3, color = "tomato")  

# change order of plotting so we can see boxplots
ggplot(data = svy, aes(x = species_id, y = hindfoot_length)) +
  geom_jitter(alpha = 0.3, color = "tomato") +
  geom_boxplot() 

# add axis labels
ggplot(data = svy, aes(x = species_id, y = hindfoot_length)) +
  geom_jitter(alpha = 0.3, color = "tomato") +
  geom_boxplot() +
  xlab("Species ID") +
  ylab("Hindfoot Length (mm)")


# Challenge: Create violin plots of the weights of each species using the geom_violin function in 
# place of the geom_boxplot function (without jitter); add appropriate axis labels and add a main 
# title using the ggtitle function.
ggplot(data = svy, aes(x = species_id, y = weight)) +
  geom_violin() +
  xlab("Species ID") +
  ylab("Weight (g)") +
  ggtitle("Weights of Small Mammal Species")

# change scale of the y axis
ggplot(data = svy, aes(x = species_id, y = weight)) +
  geom_violin() +
  xlab("Species ID") +
  ylab("Log Weight") +
  ggtitle("Weights of Small Mammal Species") + scale_y_log10()


# Longitudinal plot of number of each species over time (years) ----------------
# calculate the number of species per year
yearly_counts <- svy %>%
  group_by(year, species_id) %>%
  tally      

ggplot(data = yearly_counts, aes(x = year, y = n)) +
  geom_line() 

# create separate lines for each species
ggplot(data = yearly_counts, aes(x = year, y = n, group = species_id)) +
  geom_line()

# add colors
ggplot(data = yearly_counts, aes(x = year, y = n, group = species_id, colour = species_id)) +
  geom_line()

# faceting can be used to create separate plots for each species
ggplot(data = yearly_counts, aes(x = year, y = n, group = species_id, colour = species_id)) +
  geom_line() +
  facet_wrap(~ species_id)

ggplot(data = yearly_counts, aes(x = year, y = n, group = species_id, colour = species_id)) +
  geom_line() +
  facet_wrap(~ species_id, nrow=3)

# split each line up by sex
# create new counts data frame grouped by year, species_id, and sex
yearly_sex_counts <- svy %>%
  group_by(year, species_id, sex) %>%
  tally

ggplot(data = yearly_sex_counts, aes(x = year, y = n, color = species_id, group = sex)) +
  geom_line() +
  facet_wrap(~ species_id, nrow=3)

# makes more sense to color by sex
ggplot(data = yearly_sex_counts, aes(x = year, y = n, color = sex, group = sex)) +
  geom_line() +
  facet_wrap(~ species_id, nrow=3)

# change background theme
ggplot(data = yearly_sex_counts, aes(x = year, y = n, color = sex, group = sex)) +
  geom_line() +
  facet_wrap(~ species_id, nrow=3) +
  theme_bw()


# Challenge: Create a plot that shows the average weight of each species plotted over time (years)
# (hint: need to use dplyr to create appropriate data.frame first).
yearly_weight <- svy %>%
  group_by(year, species_id) %>%
  summarize(avg_weight = mean(weight))

ggplot(data = yearly_weight, aes(x=year, y=avg_weight, color = species_id, group = species_id)) +
  geom_line() +
  xlab("Year") +
  ylab("Average Weight (g)")

# by sex
yearly_sex_weight <- svy %>%
  group_by(year, sex, species_id) %>%
  summarize(avg_weight = mean(weight))

ggplot(data = yearly_sex_weight, aes(x=year, y=avg_weight, color = species_id, group = species_id)) +
  geom_line() +
  facet_wrap(~sex)

# facet by rows instead of columns
ggplot(data = yearly_sex_weight, aes(x=year, y=avg_weight, color = species_id, group = species_id)) +
  geom_line() +
  facet_wrap(~sex, ncol=1)

# ggplot2 cheatsheet:
# https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf

# tidyverse!

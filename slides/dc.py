
# coding: utf-8
# In[1]:
2+2
# In[2]:
print("hi everybody")
# In[3]:
a <- 5
# In[4]:
a = 5
# In[5]:
type(a)
# In[6]:
text = "hi everybody"
# In[7]:
type(text)
# In[11]:
2 * 7 # multiply
# In[10]:
2 ** 8 # a power
# In[12]:
3 > 4
# In[13]:
c(1,2,3)
# In[14]:
[1,2,3]
# In[18]:
for number in [1,2,3]:
    print(number)
# ## Store four numbers in a list
# In[20]:
# this line won't run because it starts with '#'
numbers = [1,2,3,4]
# In[21]:
help(numbers)
# In[22]:
numbers.append(5)
# In[23]:
print(numbers)
# In[24]:
# reverse the list
numbers.reverse()
# In[25]:
print(numbers)
# In[26]:
a_tuple = (1,2,3)
# In[27]:
print(a_tuple)
# ## CHALLENGE - What happens when you type `a_tuple[2]=5` vs. `a_list[1]=5`
# In[28]:
a_list=[1,2,3]
# In[29]:
a_tuple
# In[30]:
a_list
# In[31]:
a_list[0]
# In[32]:
a_tuple[0]
# In[34]:
a_list[0] = 5
print(a_list)
# In[35]:
import pandas as pd
# In[36]:
# Load in a CSV file using pandas. Note: we're referring to pandas as "pd" because we gave it a shortcut
pd.read_csv("surveys.csv")
# In[37]:
# Import CSV file with a name
surveys_df = pd.read_csv("surveys.csv")
# In[38]:
surveys_df
# In[39]:
type(surveys_df)
# In[41]:
# Show type of each column in the data frame
surveys_df.dtypes
# In[43]:
surveys_df.columns # Tells us the column names
# In[45]:
surveys_df.shape # The dimensions of the data frame
# In[47]:
surveys_df.head() # Outputs the first few rows
# In[49]:
surveys_df.head(15) # Adjust how many lines are displayed
# In[50]:
surveys_df.tail() # Shows the last few rows
# In[51]:
surveys_df['species_id'] # Show the species_id column
# In[54]:
# Pandas has "methods", but we have to specify where they are by beginning with "pd"
# Get unique species_ids
pd.unique(surveys_df['species_id'])


# Create a list of unique plot IDs in the surveys data. Call this list plot_names. How many unique plots are there in teh data? How many unique species are there in the data? HINT: the len() function returns the length of a list
plot_names = pd.unique(surveys_df['plot_id'])

# What is the difference between len(plot_names) and plot_names.nunique()?
surveys_df['plot_id'].nunique()

# Summary statistics in pandas
surveys['weight'].describe()

surveys_df['weight'].mean()
surveys_df['weight'].max()
surveys_df['weight'].min()
surveys_df['weight'].count()

# Get summary statistics grouped by certain variables
# Group data by sex
sorted_data = surveys_df.groupby('sex')

# Summary statistics for all numeric columns grouped by sex
sorted_data.describe()
#We can still get individual statistics
sorted_data.mean()

# How many recorded individuals are female and how many are male?
sorted_data.count()

# What happens when you group by two columns and use mean() to get their means?
# e.g. sorted_data2 = surveys_df.groupby(['plot_id','sex'])
sorted_data2 = surveys_df.groupby(['plot_id','sex'])
sorted_data2.mean()

# Summarize weight values for each plot in your data. (HINT: by_plot['weight'].describe())
by_plot = surveys_df.groupby('plot_id')
by_plot['weight'].describe()

# Count the number of samples by species
surveys_df.groupby('species_id')['record_id'].count()

# What about just the species "DO"?
surveys_df.groupby('species_id')['record_id'].count()['DO']

# Make a simple plot of species counts
species_counts = surveys_df.groupby('species_id')['record_id'].count()
%matplotlib inline
species_counts.plot(kind='bar');

# Plot how many animals were captured in each plot
total_count = surveys_df['record_id'].groupby(surveys_df['plot_id']).count()

total_count.plot(kind='bar');

# Create a plot of average weight per plot
weight_per_plot = surveys_df.groupby('plot_id')['weight'].mean()
weight_per_plot.plot(kind='bar');

# Create a plot of the total count males versus total females for the entire dataset?
number_per_sex = surveys_df.groupby('sex')['sex'].count()
number_per_sex.plot(kind='bar');

# Selecting subsets of the data:
surveys_df['species_id']

# As an 'attribute':
surveys_df.species_id

# More than one column by providing a "list" of columns

surveys_df[ ['species_id', 'plot_id'] ]

# What if I ask for a column that doesn't exist?
surveys_df['speciess']

# We can also choose rows instead of columns

# Get 'slice' of rows: includes the first location, but not the last
surveys_df[0:3]
surveys_df[45:80]

# Use '=' operator
ref_surveys_df = surveys_df
ref_surveys_df[0:3] = 0 # Changes "surveys_df" too!

# Using 'copy()'
true_copy_surveys_df = surveys_df.copy()
surveys_df[3:5] = 2
surveys_df.head()
true_copy_surveys_df.head()

# Re-load the data that we just screwed up
surveys_df = pd.read_csv("surveys.csv")
surveys_df.head()

# Subset data using criteria

# Just observations from 2002?
surveys_df[ surveys_df.year == 2002 ]

# Just observations not from 2002
surveys_df[ surveys_df.year != 2002 ]

# Equals: ==
# Not equals: !=
# Greater than/less than: > <
# Greater than/equal to: >=, <=
# Logical operators like & (and) | (or)

# observations between 1980 and 1985
surveys_df[(surveys_df.year >= 1980) & (surveys_df.year <= 1985)]

# Select a subset of rows in surveys_df that contain data from the year 1999 and that contain weight values less than or equal to 8. How many rows did you get?
surveys_df[ (surveys_df.year == 1999) & (surveys_df.weight <= 8)]

# You can use the 'isin' method to query based on a list
# Select only rows with species "RM" or "PP"
surveys_df[ surveys_df.species_id.isin( ["RM", "PP"] ) ]

# The ~ symbol can be used to specify the OPPOSITE of a criteria
# Select only rows with species NOT "RM" or "PP"
surveys_df[ ~surveys_df.species_id.isin( ["RM", "PP"] ) ]

# In Python, we can use the isnull() method to test whether an observation is missing:
pd.isnull(surveys_df)

# To select out only rows that do not have missing data:
# axis=1 is across columns, axis=0 would be across rows
pd.isnull(surveys_df).any(axis=1)

# Use this criteria to select only rows which have no missing data:
surveys_df[~pd.isnull(surveys_df).any(axis=1)]

# Create a data frame that contains only observations with sex values that are NOT female or male.

non_mf = surveys_df[ ~surveys_df.sex.isin( ["M","F"] ) ]

# Create a data frame that contains observations with null sex or male
null_or_m_sex = surveys_df[ surveys_df.sex.isnull() | (surveys_df.sex == "M") ]

# Combine data frames

# Read in species data frame
species_df = pd.read_csv("species.csv")

# Merge surveys data frame and species data frame on the "species_id" column:
merged = pd.merge(left=surveys_df, right=species_df, how='left', left_on='species_id', right_on='species_id')

# Plot the number of unique taxa per plot
unique_taxa_per_plot = merged.groupby('plot_id').taxa.nunique()
unique_taxa_per_plot.plot(kind='bar');

# Use unique() method:
pd.unique(merged.groupby('plot_id').taxa.nunique())

# How can we write yearly CSV files to my computer?

# os library allows you to interact with files and folders
import os

# Use os.mkdir() method to create a folder for the yearly files
os.mkdir("yearly_files")

# Use the to_csv() method to write a CSV file:
merged.to_csv("merged_data.csv")

# Use the os library to get information from our computer, like a directory listing
os.listdir("yearly_files")
os.listdir(".")

# Write a CSV containing just the data from 1999
merged[ merged.year == 1999 ]
merged[ merged.year == 1999 ].to_csv("yearly_files/merged1999.csv")

# Can we write a for loop to print a little data from each year?

# List of unique years?
merged.year.unique()

# A for loop in Python:
for year in merged.year.unique():
	print(year)
	
# Subset data for each year, print first few rows
for y in merged.year.unique():
	print(merged[ merged.year == y].head(2))

	
# Write that file to the disk:
for y in merged.year.unique():
	merged[ merged.year == y ].to_csv("yearly_files/merged" + str(y) + ".csv" )
# Code Book
Describes the raw data, the data transformation, and the end data set. The 

## Collection

The raw data was obtained from the UCI Machine Learning repository.
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

[The raw data zip file.](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

### Study's Abstract
> Abstract: Human Activity Recognition database built from the recordings of 30 subjects 
> performing activities of daily living (ADL) while carrying a waist-mounted smartphone 
> with embedded inertial sensors.

For more information regarding the study and how the data was collected consult ReadMe.txt
file in the 'UCI HAR dataset' folder.

## About the raw data

The raw data was split into *Test* and *Train* data sets. Each data set was then split 
up into three separate files. 

	* subject_(test/train).txt
	* X_(test/train).txt
	* Y_(test/train).txt

The subject text file contains the numbers 1:30 of the participants in the study. The Y 
text file contains the order list of activities (which can be found in the `activity_labels.txt`):

	1. WALKING
	2. WALKING_UPSTAIRS
	3. WALKING_DOWNSTAIRS
	4. SITTING 
	5. STANDING
	6. LAYING 
	
`Features.txt` contains the column headers.


## Data Cleaning
The files from the 'UCI HAR Dataset' was read into R using `write.table(file, header = FALSE)`

### Creating a unified data.frame
Since the data came in seperate files they were combined together to created 
a single unified data.frame. `dplyr` was used, `bind_rows()` and `bind_cols()`.

	- row bind the 'X_train' and 'X_test', 'Y_train' and 'Y_test', and
	   'subject_train' and 'subjext_test' text files.
	   		* Output being three data.frames being a combination of test 
	   		  and train data.
	- Creatd one data.frame by combining the three data.frames using column
	   bind. 
	        * Dimensions: 10299 x 563

Column names were then added using the Features.txt file

### Subsetting the data.frame
The goal was to only look at the feature values with mean() and std() in their
name. Those were selected and saved, all others were removed. This was done using
`str_detect()` of the Stringr package to create a logical vector to keep those with
mean() and std().

```
featuresmeanstd <- str_detect(FeaturesNames, pattern = (".*mean*|.*std*"))

# Knowing we would want to keep the first two columns (Subject, Activity) "TRUE" was added"
ColumnsToUse <- c(TRUE, TRUE, featuresmeanstd)
All_data <- All_data[, ColumnsToUse]
```

### Changing the Activity from numeric factors to descriptive character strings
A loop was created to loop through `All_data$Activity` and replace each numeric activity with the 
descriptive name for the activity in the activity_labels.txt file. 

### Column headers 
The column headers were cleaned up and made more descriptive. Appropriate names were added and any shortened 
words were extended to insure end user readability. Non-Alphanumeric characters were removed. 

An example of a shortened word being spelled all the way out for readability

````
str_replace_all(columnnames, pattern = "Acc", replacement = "Accelerometer");
str_replace_all(columnnames, pattern = "^f", replacement = "Frequency")
```

### Aggregation and melting
dplyr and reshape2 were used to aggregate and melt the data set for output as a tidy data set. 
The data set was aggregated by Subject and Activity. The mean was then taken for each feature.

`Aggregate_Data <- All_data %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))`

Lastly before writing the data out to a text file it was melted to comply with the 
the tidy data principles. 

```
Aggregate_Melt <- melt(Aggregate_Data,
                       id.vars = c("Subject", "Activity"),
                       variable.name = "Feature",
                       value.name = "Average Feature Value")
```

## The Tidy Data set
This is the intended output of the run_analysis.R script. 

### About the data
- Dimensions: 14220 x 4
- Column Headers:
   1. Subject: numeric value
   
   		- 1:30
   		
   2. Activity: factor value w/ 6 levels
   
      	1. WALKING
		2. WALKING_UPSTAIRS
		3. WALKING_DOWNSTAIRS
		4. SITTING 
		5. STANDING
		6. LAYING
		
   3. Feature: factor w/ 79 levels
   
   		- features from feature.txt containing mean or std.
   		
   4. Average Feature Value: numeric value
   
   		- Average of all values for each Feature for each Subject and Activity




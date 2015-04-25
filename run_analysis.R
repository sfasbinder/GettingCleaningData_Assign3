!/usr/bin/env Rscript
#                              Goals of the Script                                             
##1. Merges the training and the test sets to create one data set.
##2. Extracts only the measurements on the mean and standard deviation for each measurement. 
##3. Uses descriptive activity names to name the activities in the data set
##4. Appropriately labels the data set with descriptive variable names. 
##5. From the data set in step 4, creates a second, independent tidy data set with the average of each
##   variable for each activity and each subject.

# Data are from UCI Machine Learning Repository, "Human Activity Recognition Using Smartphones Data Set
# URL: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#----------------------      Packages Used        ---------------------------------#
library(stringr)
library(dplyr)
library(reshape2)
#----------------------------------------------------------------------------------#

#Prepwork, creating the directory and getting the file to use

if(!file.exists("./UCI HAR Dataset")){
    fileurl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	  download.file(fileurl, destfile = "./DataSet.zip")
	  unzip("DataSet.zip", overwrite = TRUE, unzip = "internal")
}


##commented out for a more reproducability and less cluter in the working directory
###fileurl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
###download.file(fileurl, destfile = "./DataSet.zip")
###unzip("DataSet.zip", overwrite = TRUE, unzip = "internal")

## read in the activity and features files
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE)
SubjTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
SubjTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
xTrain <- read.table("./UCI HAR Dataset/train/x_train.txt", header = FALSE)
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)


# 1: Merge data
## Combinding the data.frames together to make unified frames
Met_All <- bind_rows(xTrain, xTest)
Act_All <- bind_rows(yTrain, yTest)
Subj_All <- bind_rows(SubjTrain, SubjTest)

## house cleaning to free up RAM space
rm(SubjTest, SubjTrain, xTrain, xTest, yTrain, yTest, fileurl)

##Combine into the one data.frame then remove unneeded data.frames 
All_data <- bind_cols(Subj_All, Act_All, Met_All)
rm(Met_All, Act_All, Subj_All)

## Set column names
FeaturesNames <- as.character(features[,2])
colnames(All_data) <- c("Subject", "Activity", FeaturesNames)
rm(features)


#2: Extract measrurements with mean and std.deviation
## Extract out the columns with mean and std
featuresmeanstd <- str_detect(FeaturesNames, pattern = (".*mean*|.*std*"))
ColumnsToUse <- c(TRUE, TRUE, featuresmeanstd)
All_data <- All_data[, ColumnsToUse]

## cleanup
rm(FeaturesNames, featuresmeanstd, ColumnsToUse)


#3: changing "Activity" from numerals to a factor string
for(i in 1:NROW(activity_labels)){
    All_data$Activity[All_data$Activity == i] <- as.character(activity_labels[i, 2])
}

## cleanup
rm(i, activity_labels)
## fix up some of the data types
All_data$Activity <- as.factor(All_data$Activity)
All_data$Subject <- as.numeric(All_data$Subject)


#4: Relabel Column headers
## Using "feature_info.txt" to make column headers more end user friendly
## seperate the column headers from data.frame 
columnnames <- colnames(All_data)
columnnames <- str_replace_all(columnnames, pattern = "BodyBody", 
                               replacement = "Body")
columnnames <- str_replace_all(columnnames, pattern = "^t", 
                               replacement = "Time")
columnnames <- str_replace_all(columnnames, pattern = "^f", 
                               replacement = "Frequency")
columnnames <- str_replace_all(columnnames, pattern = "Gyr | Gyro", 
                               replacement = "Gyro")
columnnames <- str_replace_all(columnnames, pattern = "Acc", 
                               replacement = "Accelerometer")
columnnames <- str_replace_all(columnnames, pattern = "Mag", 
                               replacement = "Magnitude")
columnnames <- str_replace_all(columnnames, pattern = "[[:punct:]]", 
                               replacement = "")
## reassign the column headers with the fixed up column headers and then clean up
colnames(All_data) <- columnnames
rm(columnnames)


#5: Aggregate the data
Aggregate_Data <- All_data %>% group_by(Subject, Activity) %>% 
    summarise_each(funs(mean))

## Melt the data down.
Aggregate_Melt <- melt(Aggregate_Data,
                       id.vars = c("Subject", "Activity"),
                       variable.name = "Feature",
                       value.name = "Average Feature Value")

## clean up
rm(Aggregate_Data)

# Write the file as a comma delimited text file. 
write.table(Aggregate_Melt, file = "./tidy_data.txt", sep = "\t",
            row.names = FALSE, col.names = TRUE)

## writing the cleaned up data.frame (not tidy) as well for documenting all changes
write.table(All_data, file = "./Cleanedup_nottidy.txt", sep = "\t",
	    row.names = FALSE, col.names = TRUE)

## take a peak at the data.

head(Aggregate_Melt, n=5); tail(Aggregate_Melt, n=5)


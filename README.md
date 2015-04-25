# GettingCleaningData Assignment
Repository for Coursera class - Getting and Cleaning Data. 

## Data Used
The data used was from UCI Machine Learning website. Below is a link to the .zip file
containing the data used. 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Contained in the repository
All .txt files are tab delimited files.
* README.md
* R Script
     + run_analysis.R
* Code Book
* tidy_data.txt
* Cleanedup_nottidy.txt

### About the *run_analysis.R* script
The script can be run through the command line or throught the R console. It looks
for the 'UCI HAR Dataset', the output from the zipfile. If it does not find the file
in the current working directory then it will donwload the file. If the file is 
foudn then it will not re-download the file. 

It will output two files:
* tidy_data.txt
* Cleanedup_nottidy.txt

Both files are tab delimited. tidy_data.txt will output a tidy data.frame while the 
Cleanedup_nottidy.txt will contained the combination of the test and train data sets.
 
### More Info:
For more information regarding the tidy data set please consult the CodeBook included
in the repository. 

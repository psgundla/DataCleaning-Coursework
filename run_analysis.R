# HEADER --------------------------------------------
#
# Author: Pranav Swaroop Gundla
#                               
# Copyright (c) PSG, 2024
# 
# Date: 2024-04-08
# Last updated: 2026-08-31
#
# Script Name: run_analysis.R
#
# Script Description:  This is for the Data-Cleaning Course in Coursera. This is a Peer-graded review work for performing the
#                      data analysis with the tidy data.
#
#
# Notes: 
## input files: x_train.txt,x_test.txt,y_train.txt,y_test.txt,subject_train.txt,subject_test.txt
##              features.txt, activity_labels.txt
## output file: TidyDataSet.txt
##
##
## The script below uses base R only.
## The actions performed are mentioned below
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average
## of each variable for each activity and each subject.
##################################################################
##              Environment and Libraries Setup                 ##
##################################################################
# RUN FROM CURRENT WORKING DIRECTORY ----------------
cat("Working directory: ", getwd(), "\n", sep = "")

## getting the data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
expected_sha256 <- "50dabbc800629611831a85b8b71c87040525ca4af6a152c6ba9360ecee6b92dc"
expected_md5 <- "d29710c9530a31f303801b6bc34bd895"
data_directory <- file.path(getwd(), "UCI HAR Dataset")
dataset_path <- function(...) file.path(data_directory, ...)
required_files <- c(
  dataset_path("activity_labels.txt"),
  dataset_path("features.txt"),
  dataset_path("test", "subject_test.txt"),
  dataset_path("test", "X_test.txt"),
  dataset_path("test", "y_test.txt"),
  dataset_path("train", "subject_train.txt"),
  dataset_path("train", "X_train.txt"),
  dataset_path("train", "y_train.txt")
)

if (!all(file.exists(required_files))) {
  download_dataset <- function() {
    zip_path <- tempfile(fileext = ".zip")
    on.exit(unlink(zip_path), add = TRUE)

    download.file(url, zip_path, mode = "wb")
    has_sha256 <- exists(
      "sha256sum",
      envir = asNamespace("tools"),
      inherits = FALSE
    )
    if (has_sha256) {
      archive_hash <- unname(tools::sha256sum(zip_path))
      expected_hash <- expected_sha256
      hash_name <- "SHA-256"
    } else {
      archive_hash <- unname(tools::md5sum(zip_path))
      expected_hash <- expected_md5
      hash_name <- "MD5"
    }
    if (!identical(archive_hash, expected_hash)) {
      stop("Downloaded dataset failed ", hash_name, " verification")
    }

    archive_entries <- unzip(zipfile = zip_path, list = TRUE)$Name
    unsafe_entries <- grepl(
      "(^|/|\\\\)\\.\\.($|/|\\\\)|^(/|\\\\|[[:alpha:]]:)",
      archive_entries
    )
    if (any(unsafe_entries)) {
      stop("Downloaded dataset contains unsafe archive paths")
    }

    unzip(zipfile = zip_path, exdir = getwd())
  }

  download_dataset()
}

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files)) {
  stop("Dataset is incomplete; missing: ", paste(missing_files, collapse = ", "))
}

xTrain <- read.table(dataset_path("train", "X_train.txt"))
yTrain <- read.table(dataset_path("train", "y_train.txt"))
xTest <- read.table(dataset_path("test", "X_test.txt"))
yTest <- read.table(dataset_path("test", "y_test.txt"))
subTrain <- read.table(dataset_path("train", "subject_train.txt"))
subTest <- read.table(dataset_path("test", "subject_test.txt"))
activityLabels <- read.table(dataset_path("activity_labels.txt"))
features <- read.table(dataset_path("features.txt"))
## column names change
colnames(xTrain) <- features[,2]
colnames(xTest) <- features[,2]
colnames(subTrain) <- "subjectID"
colnames(subTest) <- "subjectID"
colnames(yTrain) <- "activityID"
colnames(yTest) <- "activityID"
colnames(activityLabels) <- c("activityID", "activityType")
## 1. Merging all the data table into one main set
TrainData <- cbind(xTrain,yTrain,subTrain)
TestData <- cbind(xTest,yTest,subTest)
FinalSet <- rbind(TrainData,TestData)
## 2. Extracting only the measurements on MEAN and SD.'s for each measurement
M_sd <- grepl("activityID|subjectID|mean\\(\\)|std\\(\\)",colnames(FinalSet))
setMeanStd <- FinalSet[, M_sd]

## 3. Using the descriptive activity names
setActivityNames <- merge(setMeanStd, activityLabels, by = "activityID", all.x = T)

## 4. Labeling the data with descriptive variable names
descriptive_names <- colnames(setActivityNames)
descriptive_names <- gsub("^t", "time", descriptive_names)
descriptive_names <- gsub("^f", "frequency", descriptive_names)
descriptive_names <- gsub("Acc", "Accelerometer", descriptive_names)
descriptive_names <- gsub("Gyro", "Gyroscope", descriptive_names)
descriptive_names <- gsub("Mag", "Magnitude", descriptive_names)
descriptive_names <- gsub("BodyBody", "Body", descriptive_names)
colnames(setActivityNames) <- descriptive_names
## 5. Creating the independent Tidy-Dataset with average of each variable for each activity and subject

grouping_columns <- c("subjectID", "activityID", "activityType")
measurement_columns <- setdiff(colnames(setActivityNames), grouping_columns)
TidyDataSet <- aggregate(
  setActivityNames[measurement_columns],
  by = setActivityNames[grouping_columns],
  FUN = mean
)
TidyDataSet <- TidyDataSet[order(TidyDataSet$subjectID, TidyDataSet$activityID), ]
## Writing the TidyData file
write.table(TidyDataSet, "TidyDataSet.txt", row.names = FALSE)

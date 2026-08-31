# Peer-graded Assignment: Getting and Cleaning Data Course Project

This repository contains the R script `run_analysis.R` that performs the analysis as outlined in the project requirements. The goal of this project is to demonstrate the ability to collect, work with, and clean a data set for further analysis. The data used in this project are collected from the accelerometers of the Samsung Galaxy S smartphone.

Completed by: Pranav Swaroop Gundla a.k.a BioCoderR :)

## Files in this Repository

1.  **`run_analysis.R`**: This R script performs the following steps:

    1.  Merges the training and test sets to create one data set.
    2.  Extracts only the measurements on the mean and standard deviation for each measurement.
    3.  Uses descriptive activity names to name the activities in the data set.
    4.  Appropriately labels the data set with descriptive variable names.
    5.  Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

2.  **`CodeBook.md`**: This file describes the variables, the data, and any transformations or work that was performed to clean up the data.

3.  **`TidyDataSet.txt`**: This file contains the final tidy data set with the average of each variable for each activity and each subject.

## How to Run the Script

From the repository root, run:

```sh
Rscript run_analysis.R
```

The script requires R and an internet connection on its first run. It uses base R only, with no package installation required. It downloads and extracts the [UCI HAR data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) automatically when any required input file is missing.

Successful execution writes `TidyDataSet.txt` in the current directory. The output contains 180 rows: one average-measurement row for each of 30 subjects and 6 activities. Later runs reuse the extracted `UCI HAR Dataset` directory.

## Smoke Test

Run the clean-directory regression test from the repository root:

```sh
Rscript tests/smoke_test.R
```

The test runs a copied `run_analysis.R` in a temporary directory containing the repository's tracked partial dataset, checks that missing data are downloaded, and verifies the complete 180-by-69 tidy output. It requires network access.

## About the Data

The data used in this project were collected from the accelerometers of the Samsung Galaxy S smartphone. A full description of the data is available at the following link: [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

## Code Book

For details about the variables, data, and transformations used in this analysis, please refer to the `CodeBook.md` file in this repository.

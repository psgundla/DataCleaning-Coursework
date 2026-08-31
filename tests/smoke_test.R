args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grepl("^--file=", args)]
if (length(script_arg) != 1L) {
  stop("Run this test with Rscript tests/smoke_test.R")
}

test_file <- normalizePath(sub("^--file=", "", script_arg))
repository_root <- normalizePath(file.path(dirname(test_file), ".."))
work_dir <- tempfile("data-cleaning-smoke-")
dir.create(work_dir)
on.exit(unlink(work_dir, recursive = TRUE), add = TRUE)

if (!file.copy(file.path(repository_root, "run_analysis.R"), work_dir)) {
  stop("Could not copy run_analysis.R into clean test directory")
}

# Reproduce the repository's tracked partial dataset directory. The analysis
# must detect missing required files and replace this with the full dataset.
partial_test_directory <- file.path(work_dir, "UCI HAR Dataset", "test")
dir.create(partial_test_directory, recursive = TRUE)
tracked_subject_file <- file.path(
  repository_root,
  "UCI HAR Dataset",
  "test",
  "subject_test.txt"
)
if (!file.copy(tracked_subject_file, partial_test_directory)) {
  stop("Could not reproduce the tracked partial dataset directory")
}

old_working_directory <- setwd(work_dir)
on.exit(setwd(old_working_directory), add = TRUE)

output <- system2(
  file.path(R.home("bin"), "Rscript"),
  "run_analysis.R",
  stdout = TRUE,
  stderr = TRUE
)
status <- attr(output, "status")
if (!is.null(status) && status != 0L) {
  cat(output, sep = "\n")
  stop("run_analysis.R failed with status ", status)
}

result_path <- file.path(work_dir, "TidyDataSet.txt")
if (!file.exists(result_path)) {
  stop("run_analysis.R did not create TidyDataSet.txt")
}

result <- read.table(result_path, header = TRUE, check.names = FALSE)
subject_activity <- unique(result[c("subjectID", "activityID")])
expected_activity_labels <- c(
  "LAYING",
  "SITTING",
  "STANDING",
  "WALKING",
  "WALKING_DOWNSTAIRS",
  "WALKING_UPSTAIRS"
)

stopifnot(
  identical(dim(result), c(180L, 69L)),
  nrow(subject_activity) == 180L,
  identical(sort(unique(result$activityType)), expected_activity_labels),
  !anyNA(result),
  setequal(result$subjectID, 1:30),
  setequal(result$activityID, 1:6)
)

cat("Smoke test passed: TidyDataSet.txt is a complete 180x69 tidy dataset.\n")

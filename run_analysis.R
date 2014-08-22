#Downloading file and naming it "dataset.zip"
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="dataset.zip")
#Unzipping the file
unzip(zipfile="dataset.zip", exdir=getwd())
#Assigning the file path to "dataPath" 
dataPath <- paste("./","UCI HAR Dataset",sep="/")

#1. Merging the training and test sets to create one dataset
#1.1 Merge x, y and subject train datasets with corresponding train datasets 
x_train <- read.table(file=paste(dataPath,"/train/","x_train.txt",sep=""),header=FALSE)
x_test  <- read.table(file=paste(dataPath,"/test/","x_test.txt",sep=""),header=FALSE)
y_train <- read.table(file=paste(dataPath,"/train/","y_train.txt",sep=""),header=FALSE)
y_test  <- read.table(file=paste(dataPath,"/test/","y_test.txt",sep=""),header=FALSE)
s_train <- read.table(file=paste(dataPath,"/train/","subject_train.txt",sep=""),header=FALSE)
s_test  <- read.table(file=paste(dataPath,"/test/","subject_test.txt",sep=""),header=FALSE)

#1.2 Reading features data and assigning column names to datasets
features <- read.table(file=paste(dataPath,"features.txt",sep="/"),header=FALSE)
names(x_train) <- features[,2]
names(x_test)  <- features[,2]
names(y_train) <- "Class_Label"
names(y_test)  <- "Class_Label"
names(s_test)  <- "SubjectID"
names(s_train) <- "SubjectID"

#1.3 Merging datasets into one file called "data"
xData <- rbind(x_train, x_test)
yData <- rbind(y_train, y_test)
sData <- rbind(s_train, s_test)
data <- cbind(xData, yData, sData)

#2 Extract the mean and standard deviation for each measurement, and assign it to "meanstd"
someFeatures <- features[grep("(mean|std)\\(", features[,2]),]
meanstd <- xData[,someFeatures[,1]]

#3 Assign descriptive names to the activities in the datset
labels <- read.table(file=paste(dataPath, "activity_labels.txt",sep="/"), header=FALSE)
for (i in 1:nrow(labels)) {
        code <- as.numeric(labels[i, 1])
        name <- as.character(labels[i, 2])
        yData[yData$activity == code, ] <- name
}

#4 Label the dataset with descriptive activity names
xLabels<-cbind(yData,xData)
meanstdLabels<-cbind(yData, meanstd)

#5 Create a tidy dataset with the average of each variable for each activity and subject
subTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = c('subject'))
subTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = c('subject'))
subject <- rbind(subTest, subTrain)
averages <- aggregate(xData, by = list(activity = yData[,1], subject = subject[,1]), mean)

#5.1 Create a text file called "UCI-HAR.txt" and write the data in "averages" to it.
write.csv(averages, file=paste(dataPath, "/UCI-HAR.csv",sep="/"), row.names=FALSE)

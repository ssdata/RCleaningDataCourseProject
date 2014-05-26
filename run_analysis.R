
file <- "data.zip"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
path <- "UCI HAR Dataset"
output <- "output"

##install plyr if not available locall
if(!is.element("plyr", installed.packages()[,1])){
    print("plyr not installed.. installing it")
    install.packages("plyr")
}

library(plyr)

# download the file.
if(!file.exists(file)){
    download.file(url,file, mode = "wb",method="curl")
}

#create output dir
if(!file.exists(output)){
  dir.create(output)
} 

# for the training and test data sets the columns should be features from the features.txt file
f <- unz(file, paste(path,"features.txt",sep="/"))
features <- read.table(f,sep="",stringsAsFactors=F)

## Load the data sets
name <- "train/subject_train.txt"
f <- unz(file, paste(path,name,sep="/"))
subject_data <-read.table(f,sep="",stringsAsFactors=F, col.names= "id")

name <- "train/y_train.txt"
f <- unz(file, paste(path,name,sep="/"))
y_data <-read.table(f,sep="",stringsAsFactors=F, col.names= "activity")

name <- "train/X_train.txt"
f <- unz(file, paste(path,name,sep="/"))
x_data <-read.table(f,sep="",stringsAsFactors=F, col.names= features$V2)   

train <- cbind(subject_data,y_data,x_data)

name <- "test/subject_test.txt"
f <- unz(file, paste(path,name,sep="/"))
subject_data <-read.table(f,sep="",stringsAsFactors=F, col.names= "id")

name <- "test/y_test.txt"
f <- unz(file, paste(path,name,sep="/"))
y_data <-read.table(f,sep="",stringsAsFactors=F, col.names= "activity")

name <- "test/X_test.txt"
f <- unz(file, paste(path,name,sep="/"))
x_data <-read.table(f,sep="",stringsAsFactors=F, col.names= features$V2)   

test <- cbind(subject_data,y_data,x_data)

# final data should be the combined data from the above train and test
data <- rbind(train, test)

# needs to be arranged based on id
data <- arrange(data, id)

# need to use descriptive activity names from the activity_labels.txt file
f <- unz(file, paste(path,"activity_labels.txt",sep="/"))
activity_labels <- read.table(f,sep="",stringsAsFactors=F)


data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2)



## get only the mean and standard deviation for each measurement. 
output1 <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))]


# save output1 into output folder
f <- paste(output, "/", "output1.csv" ,sep="")
write.csv(output1,f)


## second, independent tidy data set with the average of each variable for each activity and each subject. 
tidy_dataset <- ddply(output1, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) })

# appends "_avg" to colnames
colnames(tidy_dataset)[-c(1:2)] <- paste(colnames(tidy_dataset)[-c(1:2)], "_avg", sep="")

# save tidy_dataset into output folder
f <- paste(output, "/", "tidy_dataset.csv" ,sep="")
write.csv(tidy_dataset,f)

# write the codebook for the tidy dataset into CodeBook.txt
capture.output(codebook(tidy_dataset), file="CodeBook.txt")



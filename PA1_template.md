---
title: "Reproducible Research: Peer Assessment 1"
author: "henk van den berg"
output: 
  html_document:
    keep_md: true
---

Reproducible Research: Peer Assessment 1
========================================

<!--
Downloading a dataset from the internet and unzipping it into a local data
directory is a repeating chore. The `.LoadData()` function in 'load_data.R' does
just that. Because the 'activity.zip' is already part of the forked repository, 
we'll construct a local URL for the `urls` parameter of the function. But we
might also have used
https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip


```r
download.env <- new.env()
source("load_data.R", local = download.env)
download.env$.LoadData(file.path("file:/", getwd(), "activity.zip"))
```

```
## activity.zip already loaded: date of download: Fri Mar 13 14:43:13 2015
## See 'data/download_activity.zip.log' for details.
```

```r
rm(download.env)
```

Although the previous code chunck was *commented out* (for html) it is still
being processed by knitr.
-->

The dataset [Activity monitoring data][1] contains data from a personal activity 
monitoring device. This device collected data from a single person at 5 minute 
intervals through out
the day, during the months of October and November, 2012.  
The dataset is downloaded and unzipped in a single file as `data/activity.csv`.

## Loading and preprocessing the data

We can inspect the raw data by reading the first lines from the data file...

```r
data.file <- "data/activity.csv"
cat("<pre>\n", paste0(readLines(data.file, n = 5), collapse = "<br/>"), "\n</pre>", sep = "")
```

<pre>
"steps","date","interval"<br/>NA,"2012-10-01",0<br/>NA,"2012-10-01",5<br/>NA,"2012-10-01",10<br/>NA,"2012-10-01",15
</pre>

As we can see and already know from [other sources] [2] the data has 3 fields:

- **steps**: Number of steps taking in a 5-minute interval 
(missing values are coded as NA)
- **date**: The date on which the measurement was taken in YYYY-MM-DD format
- **interval**: Identifier for the 5-minute interval in which measurement was 
taken

A <a href="data/activity.csv" target="_blank">further inspection</a> of the data 
reveals several other things.
It looks like the `interval` is computed as *24-hour-digit + amount-of-minutes*,
so we can recompute `date` and `interval` as a continuous `time` field of 
type [POSIXct] [3]. But first, read in the raw data:


```r
data <- read.csv(data.file, stringsAsFactors = FALSE)
library(knitr)
kable(tail(data, n = 3), format = "markdown")
```



|      | steps|date       | interval|
|:-----|-----:|:----------|--------:|
|17566 |    NA|2012-11-30 |     2345|
|17567 |    NA|2012-11-30 |     2350|
|17568 |    NA|2012-11-30 |     2355|

Create an extra `time` field on basis of `date` and `interval` values:


```r
data$time <- as.POSIXct(paste0(data$date, " ", as.integer(data$interval/100), 
        ":", data$interval %% 100))

kable(data[287:292, ], format = "markdown")
```



|    | steps|date       | interval|time                |
|:---|-----:|:----------|--------:|:-------------------|
|287 |    NA|2012-10-01 |     2350|2012-10-01 23:50:00 |
|288 |    NA|2012-10-01 |     2355|2012-10-01 23:55:00 |
|289 |     0|2012-10-02 |        0|2012-10-02 00:00:00 |
|290 |     0|2012-10-02 |        5|2012-10-02 00:05:00 |
|291 |     0|2012-10-02 |       10|2012-10-02 00:10:00 |
|292 |     0|2012-10-02 |       15|2012-10-02 00:15:00 |

Here is a summary of the preprocessed data:

```r
kable(summary(data), format = "markdown")
```



|   |    steps        |    date           |   interval      |     time                     |
|:--|:----------------|:------------------|:----------------|:-----------------------------|
|   |Min.   :  0.00   |Length:17568       |Min.   :   0.0   |Min.   :2012-10-01 00:00:00   |
|   |1st Qu.:  0.00   |Class :character   |1st Qu.: 588.8   |1st Qu.:2012-10-16 05:58:45   |
|   |Median :  0.00   |Mode  :character   |Median :1177.5   |Median :2012-10-31 11:57:30   |
|   |Mean   : 37.38   |NA                 |Mean   :1177.5   |Mean   :2012-10-31 11:30:49   |
|   |3rd Qu.: 12.00   |NA                 |3rd Qu.:1766.2   |3rd Qu.:2012-11-15 17:56:15   |
|   |Max.   :806.00   |NA                 |Max.   :2355.0   |Max.   :2012-11-30 23:55:00   |
|   |NA's   :2304     |NA                 |NA               |NA                            |

## What is mean total number of steps taken per day?

```r
aggdata1 <- aggregate(steps ~ date, data = data, sum)
aggdata2 <- aggregate(data$steps, by=list(data$date), FUN=sum, na.rm=TRUE)

meantotal <- as.integer(mean(aggdata1$steps))
mediantotal <- median(aggdata1$steps)
```

There are 2304 missing values in 
the `steps` field.
While ignoring missing values, we can still calculate the number of steps
taken per day.  Depending on whether we want to include days with apparantly 
no values taken we have 53 (aggdata1) or 61 
(aggdata2) days where we
can calculate the total number of steps. And from there the mean total of steps
per day.

If we do not want missing values affect the mean calculation too much, we
go for the aggdata1 aggregation and
arive at a mean total of 10766 steps taken per day.


```r
hist(aggdata1$steps,
     main="Histogram of total amount of steps per day", 
     xlab="steps per day (October - November, 2012)",
     col = "lavender")
abline(v = meantotal, col = "blue", lwd = 2, lty = 2)
abline(v = mediantotal, col = "red", lwd = 1, lty = 5)
```

![plot of chunk histsteps](figure/histsteps-1.png) 

It appears there is a symetric distribution of the data, with mean and median 
values almost equal.

Mean total steps per day: 10766 (blue)  
Median total steps per day:  10765 (red)

## What is the average daily activity pattern?



## Imputing missing values



## Are there differences in activity patterns between weekdays and weekends?


***
[1]: https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip
[2]: https://github.com/rdpeng/RepData_PeerAssessment1/blob/master/README.md
[3]: https://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html


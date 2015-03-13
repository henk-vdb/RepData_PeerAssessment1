# This script can be used to download files from the internet.
#
# - All downloaded files will be in the folder 'data', relative to the 
#   working directory.
# - If the path in the url ends with '.zip', the file will be unzipped.
# - A log file with details about the download will be created.
# - Files already present will not be downloaded again.
#
# 
# Specify URL's in the section 'Direct execution' below or 
# call .LoadData() from the command line.
# 
# Tested on Mac. For Widows change the 'method = "curl"' parameter in
# line 37 below.

# This script runs in its own environment.
load.data.env <- new.env()

#' Load files and unzip them in the folder data.
#' @param urls - character vector. the url(s) to download.
.LoadData <- local(function(urls) {
        datafolder <- "data" 
        
        if (!file.exists(datafolder)) {
                message("Creating a data folder: '", datafolder, "'.")
                dir.create(datafolder)
        }
        
        for (url in urls) {
                filename <- basename(URLdecode(url))
                logfile <- file.path(datafolder, paste0("download_", filename, ".log"))
                downloadfile <- file.path(datafolder, filename)  
                
                if (!file.exists(downloadfile)) {
                        message("Downloading '", url, "'.")
                        # no 'curl' status code transfered, cannot know if download succeeds,
                        # unless an error occurs.
                        download.file(url, destfile = downloadfile, method = "curl", quiet = TRUE)
                        date.downloaded <- date()
                        message("Downloaded '", downloadfile, "' on ", date.downloaded)
                        
                        if (grepl(".zip$", downloadfile)) {
                                result <- unzip(downloadfile, exdir = datafolder)
                                nfiles <- length(result)
                                message("Unzipped ", nfiles, " file(s).")
                        } else {
                                nfiles <- 1; result <- downloadfile
                        }
                        
                        start.rel.path <- nchar(datafolder) + 2
                        cat("source: ", url,
                            "\ndate of download: ", date.downloaded,
                            "\nnumber of files: ", nfiles,
                            "\nlist of files:\n", paste(substring(result, start.rel.path), 
                                                        collapse = "\n"),
                            "\n",
                            file = logfile, sep = "")
                } else {
                        lines <- readLines(logfile)
                        message(filename, " already loaded: ", lines[2])
                }
                message("See '", logfile, "' for details.\n")
        }
}, env = load.data.env)


################################################################################
# Direct execution
################################################################################
# Load the following data:
#.LoadData("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip")
# Specify as many urls as you like. caveat: filenames should be unique.
#.LoadData("http://xweb.geos.ed.ac.uk/~weather/jcmb_ws/JCMB_2014_Dec.csv")
#.LoadData("http://www.telize.com/geoip/")

################################################################################
# cleanup
rm(load.data.env)
################################################################################

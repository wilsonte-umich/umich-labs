# general support utilities

# read an entire text file
slurpFile <- function(fileName) readChar(fileName, file.info(fileName)$size)

# missign value handling
is.absent <- function(x) is.null(x) || is.na(x)
naToNull <- function(x) if(is.na(x)) NULL else x

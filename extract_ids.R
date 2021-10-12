# initialize
library(yaml)
setwd(dirname(parent.frame(2)$ofile))
config <- list()

# load _data files
dataTypes <- c('people', 'publications', 'funding', 'resources')
for(type in dataTypes){
    config[[type]] <- read_yaml(paste0('_data/', type, '.yml'))
}

# load _content files
contentTypes <- c('projects', 'newsfeed')
for(type in contentTypes){
    config[[type]] <- list()
    files <- list.files(paste0('content/_', type),  full.names = TRUE)
    for(file in files){
        if(!endsWith(file, "_README") && !endsWith(file, "_archive")){
            id <- strsplit(file, '/')[[1]][3]
            id <- strsplit(id, '\\.')[[1]][1]
            config[[type]][[id]] <- read_yaml(file)
            config[[type]][[id]]$id <- id 
        }
    }
}

# extract all known badges
badgeTypes <- c('projects', dataTypes)
types <- list(
    projects = 'project',
    newsfeed = 'post',
    people = 'person',
    publications = 'publication',
    funding = 'funding',
    resources = 'resource'
)
allowedBadges <- unname(unlist( lapply(badgeTypes, function(type){
    lapply(config[[type]], function(x){
        paste0(types[[type]], '=', x$id)
    })
}) ))
isBadBadge <- FALSE
message()
declaredBadges <- unname(unlist( lapply(names(types), function(type){
    lapply(config[[type]], function(x) {
        for(badge in x$badges){
            if(!(badge %in% allowedBadges)) {
                print("!!! BAD BADGE !!!")
                print(paste("source =", type, x$id))
                print(paste("unknown badge = ", badge))
                isBadBadge <<- TRUE
                message()
            }
        }
        x$badges
    })
}) ))
if(isBadBadge) {
    message()
    message("known badges:")
    print(allowedBadges)
    message()
    # stop("stopping with bad badges")
}

message("declared badges:")
print(declaredBadges)

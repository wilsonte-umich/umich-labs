# type conversion lists
Collections <- list(
    project = 'projects',
    person = 'people',
    publication = 'publications',
    resource = 'resources',
    event = 'events',    
    funding = 'funding',
    post = 'newsfeed'
)
ItemTypes <- list(
    projects = 'project',
    people = 'person',
    publications = 'publication',
    resources = 'resource',
    events = 'event',    
    funding = 'funding',
    newsfeed = 'post'
)
DataTypes <- c('people', 'publications', 'funding', 'resources', 'events') # found in _data
ContentTypes <- c('projects', 'newsfeed') # not found in _data, always have a markdown file

# load and save the site's configuration data files
# List of 9
#  $ people        :List of 3
#   ..$ :List of 9
#   .. ..$ id     : chr "John_Doe"
loadSiteConfig <- function(){
    message(paste('loading site configuration', rootDir))
    config <- list()

    # load _data files
    for(type in DataTypes) config[[type]] <- read_yaml(paste0(rootDir, '/', '_data/', type, '.yml'))

    # load _content files
    for(type in ContentTypes){
        config[[type]] <- list()
        files <- list.files(paste0(rootDir, '/', 'content/_', type),  full.names = TRUE)
        for(file in files){
            if(!endsWith(file, "_README") && !endsWith(file, "_archive")){
                id <- rev(strsplit(file, '/')[[1]])[1]
                id <- strsplit(id, '\\.')[[1]][1]
                x <- slurpFile(file)
                x <- gsub('\r', '', x)
                x <- strsplit(x, "---\n")[[1]]
                config[[type]][[id]] <- read_yaml(text = paste0("---\n", x[2]))
                config[[type]][[id]]$id <- id 
            }
        }
    }

    # extract all known badges
    config$allowedBadges <- unname(unlist( lapply(c(ContentTypes, DataTypes), function(type){
        lapply(config[[type]], function(x){
            paste0(ItemTypes[[type]], '=', x$id)
        })
    }) ))

    config$declaredBadges <- unname(unlist( lapply(names(ItemTypes), function(type){
        lapply(config[[type]], function(x) {
            for(badge in x$badges){
                if(!(badge %in% config$allowedBadges)) {
                    print("!!! BAD BADGE !!!")
                    print(paste("source =", type, x$id))
                    print(paste("unknown badge = ", badge))
                    message()
                }
            }
            x$badges
        })
    }) ))

    # return the results
    config
}

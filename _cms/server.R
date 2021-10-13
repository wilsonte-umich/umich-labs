MainButtons <- list(
    projectsButton = list(collection = 'projects', itemType = 'project'), 
    peopleButton = list(collection = 'people', itemType = 'person'), 
    publicationsButton = list(collection = 'publications', itemType = 'publication'), 
    resourcesButton = list(collection = 'resources', itemType = 'resource'), 
    fundingButton = list(collection = 'funding', itemType = 'funding'), 
    newsfeedButton = list(collection = 'newsfeed', itemType = 'post')
)
Collections <- list(
    project = 'projects',
    person = 'people',
    publication = 'publications',
    resource = 'resources',
    funding = 'funding',
    post = 'newsfeed'
)
button <- "margin: 5px 0;"
server <- function(input, output) { 
    source('utilities.R', local = TRUE)

    # initialize variables
    mainButtons <- c(reactiveVal(NULL), reactiveVal(NULL))
    collections <- c(reactiveVal(NULL), reactiveVal(NULL))
    itemTypes   <- c(reactiveVal(NULL), reactiveVal(NULL))
    itemIs      <- c(reactiveVal(NULL), reactiveVal(NULL))
    badgeJs     <- c(reactiveVal(NULL), reactiveVal(NULL))


    # # extract the item of a clicked badge
    # output$sisters <- renderUI({

    #     message('output$sisters')
    #     req(badgeJ())
    #     badge <- config[[collection()]][[itemI()]]$badges[[badgeJ()]]
    #     badge <- strsplit(badge, '=')[[1]]
    #     items <- config[[collections[[badge[1]]]]]
    #     match <- sapply(items, function(x) x$id == badge[2])
    #     sister <- items[match][[1]]

    #     str(sister)

    #     lapply(seq_along(sister$badges), function(k){
    #         buttonId <- paste0('sister_', k)

    #         print(sister$badges[k]) 
    #         actionButton(buttonId, sister$badges[k], width = "100%", style = button)
    #     })
    # })

    # # load existing badges
    # output$badges <- renderUI({
    #     req(itemI())
    #     badges <- config[[collection()]][[itemI()]]$badges
    #     lapply(seq_along(badges), function(j){
    #         buttonId <- paste0('badge_', j)
    #         actionButton(buttonId, badges[j], width = "100%", style = button)
    #     })
    # })
    # lapply(1:100, function(j){
    #     buttonId <- paste0('badge_', j)
    #     observeEvent(input[[buttonId]], {
    #         badgeJ(j)
    #     })
    # })

    # load a set of items
    lapply(1:2, function(n){
        output[[paste0('items', n)]] <- renderUI({
            req(mainButtons[[n]]())
            collection <- MainButtons[[mainButtons[[n]]()]]$collection
            items <- config[[collection]]        
            lapply(seq_along(items), function(i){
                buttonId <- paste0('item_', n, '_', i)   
                actionButton(buttonId, items[[i]]$id, width = "100%", style = button)
            })
        })
        lapply(1:100, function(i){
            buttonId <- paste0('item_', n, '_', i)   
            observeEvent(input[[buttonId]], {
                badgeJs[[n]](NULL)
                itemIs[[n]](i)
            })
        })
    })

    # react to collection selection
    lapply(1:2, function(n){
        lapply(names(MainButtons), function(buttonName){
            buttonId <- paste0(buttonName, n)
            print(buttonId)
            observeEvent(input[[buttonId]], {
                badgeJs[[n]](NULL)
                itemIs[[n]](NULL)
                mainButtons[[n]](buttonName)
            })            
        })
    })
}

# List of 6
#  $ people      :List of 3
#   ..$ :List of 9
#   .. ..$ id     : chr "John_Doe"

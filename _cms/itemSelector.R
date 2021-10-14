#----------------------------------------------------------------------
# module for finding an items and listing its badges
CollectionLabels <- list(
    projects = 'Project',
    people = 'People',
    publications = 'Publications',
    resources = 'Resources',
    events = 'Events',    
    funding = 'Funding',
    newsfeed = 'Newsfeed'
)
MainButtons <- list(
    projectsButton = list(name = 'projects', itemType = 'project'), 
    peopleButton = list(name = 'people', itemType = 'person'), 
    publicationsButton = list(name = 'publications', itemType = 'publication'), 
    resourcesButton = list(name = 'resources', itemType = 'resource'), 
    eventsButton = list(name = 'events', itemType = 'event'),     
    fundingButton = list(name = 'funding', itemType = 'funding'), 
    newsfeedButton = list(name = 'newsfeed', itemType = 'post')
)
#----------------------------------------------------------------------
# MODULE UI
#----------------------------------------------------------------------
panelCommon <- "display: inline-block; padding: 5px; border: 1px solid #ccc; overflow: clip;"
button <- "margin: 2px 0; padding: 4px 0;"
itemSelectorUI <- function(id, i) {
    ns <- NS(id)
    box(
        width = 6,
        style = "padding: 0; margin: 0;",
        title = paste0("Select Item #", i),
        status = 'primary',
        solidHeader = TRUE,
        div(style = "display: flex;",
            div(style = paste("width: 90px;", panelCommon), lapply(names(CollectionLabels), function(name){
                actionButton(ns(paste0(name, 'Button')), CollectionLabels[[name]], 
                            width = "100%", style = button)
            })),
            div(style = paste("width: 125px;", panelCommon), uiOutput(ns("items"))),
            div(style = paste("width: 175px;", panelCommon), uiOutput(ns("badges")))             
        )
    )
}
#----------------------------------------------------------------------
# BEGIN MODULE SERVER
#----------------------------------------------------------------------
itemSelectorServer <- function(id, i) {
    moduleServer(id, function(input, output, session) {
        ns <- NS(id) # in case we create inputs, e.g. via renderUI
        module <- 'itemSelector' # for reportProgress tracing
#----------------------------------------------------------------------

# load existing badges
output$badges <- renderUI({
    req(item())
    badges <- item()$badges
    lapply(seq_along(badges), function(j){
        buttonId <- paste0('badge_', j)
        actionButton(ns(buttonId), badges[j], width = "100%", style = button)
    })
})

# load a set of items
item <- reactive({
    req(itemI())
    i <- itemI()
    item <- collection()$items[[i]]
    list(
        i = i,
        id = item$id,
        type = collection()$itemType,
        badge = paste(collection()$itemType, item$id, sep = "="), # this items badge (for use by others)
        badges = item$badges, # the badges declared by this item
        title = item$title
    )
})
itemI <- reactiveVal(NULL)
output$items <- renderUI({
    req(collection())
    items <- collection()$items       
    lapply(seq_along(items), function(i){
        buttonId <- paste0('item_', i)   
        actionButton(ns(buttonId), items[[i]]$id, width = "100%", style = button)
    })
})
lapply(1:100, function(i){
    buttonId <- paste0('item_', i) 
    observeEvent(input[[buttonId]], {
        # badgeJ(NULL)
        itemI(i)
    })
})

# react to collection selection
collection <- reactive({
    req(mainButton())
    x <- MainButtons[[mainButton()]]
    x$items <- config()[[x$name]]
    x
})
mainButton <- reactiveVal(NULL)
lapply(names(MainButtons), function(buttonName){
    observeEvent(input[[buttonName]], {
        # badgeJ(NULL)
        itemI(NULL)
        mainButton(buttonName)
    })            
})

# module return value
list(
    collection = collection,
    item = item
)

#----------------------------------------------------------------------
# END MODULE SERVER
#----------------------------------------------------------------------
})}
#----------------------------------------------------------------------

# main CMS server function
server <- function(input, output, session) { 
    source('utilities.R', local = TRUE)

    # load all site data
    source('config.R', local = TRUE)
    config <- reactiveVal( loadSiteConfig() )

    # handle PubMed import
    confirmPubmedData <- reactiveVal(NULL)
    source('importPubMed.R', local = TRUE)
    observeEvent(input$pubmedImport, { importPubMed() })
    output$confirmPubmedImport <- renderUI({ confirmPubmedImport() })

    # handle images viewing and path generation
    source('images.R', local = TRUE)

    # handle badge generation
    source('itemSelector.R', local = TRUE)
    source('itemReporter.R', local = TRUE)
    item1 <- itemSelectorServer('item1', 1)
    item2 <- itemSelectorServer('item2', 2)
    itemReporterServer('item1', 1, item1)
    itemReporterServer('item2', 2, item2)

    # handle item linking
    output$linkAction <- renderUI({
        req(item1$item())
        req(item2$item())
        x1 <- item1$item()
        x2 <- item2$item()
        req(x1$type != 'post') # can't tag posts in UI (must edit _content file), and items never tag posts
        req(x2$type != 'post')
        req(x1$type != x2$type) # we never link items of the same type
        if((x1$badge %in% x2$badges && x2$badge %in% x1$badges) ||
           (x1$type == 'project' && x1$badge %in% x2$badges) || # projects are not tagged, and items can tag projects
           (x2$type == 'project' && x2$badge %in% x1$badges)){
            actionButton('removeLinkButton', "REMOVE", width = "100%", style = button)
        } else {
            actionButton('addLinkButton', "ADD", width = "100%", style = button)
        }
    })
    observeEvent(input$addLinkButton, {
        x1 <- item1$item()
        x2 <- item2$item()
        c1 <- item1$collection() # a list of items, same as a _data collection, except NAMED
        c2 <- item2$collection()
        if(x1$type != 'project'){
            message('will tag')
            message(x1$badge)
        }
        if(x2$type != 'project'){
            message('will tag')
            message(x2$badge)
        }
    })
    observeEvent(input$addLinkButton, {
        x1 <- item1$item()
        x2 <- item2$item()
        c1 <- item1$collection()
        c2 <- item2$collection()
    })  
}

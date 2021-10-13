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
    changeItemBadges <- function(remove){
        cfg <- config()
        changeItemBadge <- function(c, x, changingBadge, remove){
            if(is.null(x$badges)) x$badges <- character()     
            if(remove) badges <- x$badges[x$badges != changingBadge]
                else badges <- unique(c(x$badges, changingBadge))
            if(length(badges) == 0) badges <- NULL
            cfg[[c$name]][[x$i]]$badges <<- badges
            out <- cfg[[c$name]]
            names(out) <- NULL
            outFile     <- paste0(rootDir, '/', '_data/', c$name, '.yml')
            archiveFile <- paste0(rootDir, '/', '_data/_archive/', c$name, '-', Sys.Date(), '.yml')
            file.copy(outFile, archiveFile, overwrite = FALSE)
            write_yaml(out, outFile)
        }
        c1 <- item1$collection()
        c2 <- item2$collection()        
        x1 <- item1$item()
        x2 <- item2$item()
        if(x1$type != 'project') changeItemBadge(c1, x1, x2$badge, remove)
        if(x2$type != 'project') changeItemBadge(c2, x2, x1$badge, remove)
        config(cfg)   
    }
    observeEvent(input$removeLinkButton, { changeItemBadges(TRUE) })
    observeEvent(input$addLinkButton,    { changeItemBadges(FALSE) })
}

#----------------------------------------------------------------------
# pubmed import UI
#----------------------------------------------------------------------
pubmedUI <- function(...){
    tagList(
        tags$ul(
            tags$li("go to ", "PubMed"), #a("PubMed", href = "https://pubmed.ncbi.nlm.nih.gov/")),
            tags$li("execute a search"),
            tags$li("set Display Options to 'PubMed'"),
            tags$li("copy entire contents to clipboad (e.g., Ctrl-A, Ctrl-C)"),
            tags$li("paste into the box below (e.g., Ctrl-V)")
        ),
        textAreaInput('pubmedImport', 'Paste PubMed formatted citations list here', rows = 5, width = '100%'),
        uiOutput('confirmPubmedImport')
    )
}

#----------------------------------------------------------------------
# images viewing and link generation
#----------------------------------------------------------------------
imagesUI <- function(...){
    fluidRow(
        tags$ul(
            tags$li("To add an image, drag and drop it into Visual Studio Code into the proper folder under 'assets/images'."), # nolint
            tags$li("You may need to reload this browser."),
            tags$li("Copy the file path into 'card_image' or other image tag.")
        ),
        box(
            width = 7,
            title = "File Selector",
            status = 'primary',
            solidHeader = TRUE,
            collapsible = TRUE,
            # custom search box
            shinyTree(
                "fileTree",
                checkbox = FALSE,
                search = FALSE,
                searchtime = 250,
                dragAndDrop = FALSE,
                types = NULL,
                theme = "default",
                themeIcons = FALSE,
                themeDots = TRUE,
                sort = FALSE,
                unique = FALSE,
                wholerow = TRUE,
                stripes = FALSE,
                multiple = FALSE,
                animation = 200,
                contextmenu = FALSE
            )
        ),
        box(
            width = 5,
            title = "Selected Image",
            status = 'primary',
            solidHeader = TRUE,
            textInput('imagePathCopy', '', ''),
            textOutput('imageSize'),
            imageOutput('selectedImage')
        )
    )
}

#----------------------------------------------------------------------
# badge generation and item linking
#----------------------------------------------------------------------
badgesUI <- function(...){
    source('itemSelector.R', local = TRUE)
    source('itemReporter.R', local = TRUE)
    tagList(
        tags$ul(
            tags$li("Select two items and click ADD or REMOVE to establish a badge link between them."), # nolint
            tags$li("Copy a badge into a news post's markdown file as needed.")
        ),     
        fluidRow(
            itemReporterUI('item1', 1),
            box(
                width = 2,
                title = "-LINK-",
                status = 'primary',
                solidHeader = TRUE,
                uiOutput('linkAction')
            ),
            itemReporterUI('item2', 2)
        ),
        fluidRow(
            itemSelectorUI('item1', 1),
            itemSelectorUI('item2', 2)
        )
    )
}

#----------------------------------------------------------------------
# set up the CMS page layout
#----------------------------------------------------------------------
# htmlHeadElements <- function(){
#         tags$head(
#         # tags$link(rel = "icon", type = "image/png", href = "logo/favicon-16x16.png"), # favicon
#         # tags$link(href = "framework.css", rel = "stylesheet", type = "text/css"), # framework js and css
#         # tags$script(src = "framework.js", type = "text/javascript", charset = "utf-8"),
#         tags$script(src = "ace/src-min-noconflict/ace.js", type = "text/javascript", charset = "utf-8")
#     )
# }
getTabMenuItem <- function(tabId, tabLabel){
    menuItem(
        tags$div(tabLabel,  class = "sidebar-action"), 
        tabName = tabId
    )  
}
getTabItem <- function(tabId, uiFn){
    tabItem(
        tabName = tabId, 
        uiFn(tabId)
    )
}
ui <- function(...){ 
    dashboardPage(
        dashboardHeader(
            title = "umich-labs",
            titleWidth = "175px"
        ),
        dashboardSidebar(
            sidebarMenu(id = "sidebarMenu",  
                getTabMenuItem('badges', 'Badges'),
                getTabMenuItem('images', 'Images'),                  
                getTabMenuItem('pubmed', 'Import Pubmed')      
            ),
            # htmlHeadElements(), # yes, place the <head> content here (even though it seems odd)
            width = "175px" # must be here, not in CSS
        ),
        dashboardBody(
            useShinyjs(), # enable shinyjs
            tabItems(              
                getTabItem('pubmed', pubmedUI),
                getTabItem('images', imagesUI),
                getTabItem('badges', badgesUI)
            )
        )
    )
}

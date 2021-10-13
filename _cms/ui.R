itemPanel <- "display: flex; margin-bottom: 10px;"
narrowPanel <- "width: 120px; display: inline-block; padding: 5px; border: 1px solid #ccc;"
widePanel   <- "width: 200px; display: inline-block; padding: 5px; border: 1px solid #ccc;"
button <- "margin: 5px 0;"
ui <- fluidPage(
    style = "padding: 15px",
    div(style = itemPanel,
        div(style = narrowPanel,
            actionButton('projectsButton1',     'Projects',     width = "100%", style = button),
            actionButton('peopleButton1',       'People',       width = "100%", style = button),
            actionButton('publicationsButton1', 'Publications', width = "100%", style = button),
            actionButton('resourcesButton1',    'Resources',    width = "100%", style = button),
            actionButton('fundingButton1',      'Funding',      width = "100%", style = button),
            actionButton('newsfeedButton1',     'Newsfeed',     width = "100%", style = button)
        ),
        div(id = "itemPanel1",  style = widePanel, uiOutput("items1")),
        div(id = "badgePanel1", style = widePanel, uiOutput("badges1")) 
    ),
    # ,
    # div(id = "sisterPanel1", style = widePanel, uiOutput("sisters1"))

    div(style = itemPanel,
        div(style = narrowPanel,
            actionButton('projectsButton2',     'Projects',     width = "100%", style = button),
            actionButton('peopleButton2',       'People',       width = "100%", style = button),
            actionButton('publicationsButton2', 'Publications', width = "100%", style = button),
            actionButton('resourcesButton2',    'Resources',    width = "100%", style = button),
            actionButton('fundingButton2',      'Funding',      width = "100%", style = button),
            actionButton('newsfeedButton2',     'Newsfeed',     width = "100%", style = button)
        ),
        div(id = "itemPanel2",  style = widePanel, uiOutput("items2")),
        div(id = "badgePanel2", style = widePanel, uiOutput("badges2")) 
    )
    # ,
    # div(id = "sisterPanel2", style = widePanel, uiOutput("sisters2")) 

)

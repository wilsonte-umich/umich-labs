#----------------------------------------------------------------------
# initialize file selector tree
#----------------------------------------------------------------------

# store file paths for validating leaf status (i.e. file, not directory)
treeFiles <- character()
relImagesDir <- file.path('assets', 'images')
imagesDir <- file.path(rootDir, relImagesDir)

# render the file tree
output$fileTree <- renderTree({

    # collect and sort the files list
    treeFiles <<- list.files(imagesDir, recursive = TRUE)
    x <- strsplit(treeFiles, '/')
    lenX <- sapply(x, length)
    maxLen <- max(lenX)
    x <- cbind(lenX == 1, as.data.frame(t(sapply(seq_along(x), function(i) c(x[[i]], rep(NA, maxLen - lenX[i]))))))
    order <- do.call(order, x)
    x <- x[order, ][, 2:ncol(x)]
    lenX <- lenX[order]
    nRows <- nrow(x)
    req(nRows)
    rowIs <- 1:nRows

    # process the files list is a list of lists compatible with ShinyTree
    # note that it is the names (not the values) of the list that represent the tree content
    parseLevel <- function(rows, col){
        uniqNames <- unique(x[rows, col])
        list <- lapply(uniqNames, function(name){
            rows_ <- which(x[[col]] == name & rowIs %in% rows)
            if(length(rows_) == 1 && lenX[rows_] == col) '' # a terminal leaf (i.e. a file)
            else parseLevel(rows_, col + 1) # a node (i.e. a directory)
        })
        names(list) <- uniqNames
        list
    }
    parseLevel(rowIs, 1) # recurse through the file structure
})

# respond to a file tree click
selectedImagePath <- reactive({
    req(input$fileTree)
    x <- get_selected(input$fileTree)
    req(length(x) == 1) # == 0 when not selected; never >0 since multi-select disabled
    x <- x[[1]]
    x <- paste(c(attr(x, 'ancestry'), x), collapse = "/") # reassemble the file path relative to tree root
    req(x %in% treeFiles)
    relPath <- file.path(relImagesDir, x)
    updateTextInput(session, 'imagePathCopy', value = relPath)
    file.path(rootDir, relPath)
})
output$imageSize <- renderText({
    req(selectedImagePath())    
    paste0(round(file.size(selectedImagePath()) / 1000), "KB")
})
output$selectedImage <- renderImage({
    req(selectedImagePath())    
    list(
        src = selectedImagePath(),
        width = '100%',
        style = "margin-top: 10px;"
    )
}, deleteFile = FALSE)

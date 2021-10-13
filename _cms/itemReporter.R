#----------------------------------------------------------------------
# module for reporting on the contents of a selected item
#----------------------------------------------------------------------
# MODULE UI
#----------------------------------------------------------------------
itemReporterUI <- function(id, i) {
    ns <- NS(id)
    box(
        width = 5,
        title = paste("Item #", i, " Badge"),
        status = 'primary',
        solidHeader = TRUE,
        textInput(ns('itemCopy'), '', '')
    )
}
#----------------------------------------------------------------------
# BEGIN MODULE SERVER
#----------------------------------------------------------------------
itemReporterServer <- function(id, i, item) {
    moduleServer(id, function(input, output, session) {
        ns <- NS(id) # in case we create inputs, e.g. via renderUI
        module <- 'itemReporter' # for reportProgress tracing
#----------------------------------------------------------------------

# show the proper badge for the selected item
observe({
    req(item$item())
    updateTextInput(session, 'itemCopy', value = item$item()$badge)
})

# module return value
NULL

#----------------------------------------------------------------------
# END MODULE SERVER
#----------------------------------------------------------------------
})}
#----------------------------------------------------------------------

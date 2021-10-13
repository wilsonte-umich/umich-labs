# load packages, install if missing
packages <- c(
    'shiny',
    'shinydashboard',
    'shinyTree',
    'shinyjs',    
    'yaml'
)
package.check <- lapply(
    packages,
    function(x){
        message(paste('checking package:', x))
        if (!require(x, character.only = TRUE)){
            install.packages(x, dependencies = TRUE)
            library(x, character.only = TRUE)
        }
    }
)

# set directories
rootDir <- dirname(parent.frame(2)$ofile)
setwd(rootDir)
setwd('_cms')

# run the Shiny app
runApp(launch.browser = TRUE, port = 8000)

# parse the incoming PubMed formatted citations and compare to existing citations
importPubMed <- function(){
    confirmPubmedData(NULL)
    req(input$pubmedImport)

    # load and parse import the PubMed input file
    message('loading incoming citations')
    d <- input$pubmedImport
    d <- gsub('\\r', '', d)
    d <- gsub('\\n      ', ' ', d)
    d <- strsplit(d, '\\n\\n')[[1]] # result is one text block per citation

    # parse known publications already entered into the site
    publications <- config()$publications
    x <- sapply(publications, function(x) x$pmid)
    pmids <- if(length(x) > 0) seq_along(x) else integer()
    names(pmids) <- x

    # process each incoming citation (use of data frame is legacy, could debug easily)
    # https://www.nlm.nih.gov/bsd/mms/medlineelements.html
    df <- data.frame() # missing fields remain NA, or possibly column will be missing
    fields <- list(
        DP = "NA", #"2019 May 2"  DEP = 20190404    
        PMID = "pmid",
        PMC = "pmcid",
        AU = "authors",
        TI = "title",
        TA = "journal",
        VI = "volume",
        IP = "issue",
        PG = "pages",
        SO = "source", # "Cell. 2019 May 2;177(4):837-851.e28. doi: 10.1016/j.cell.2019.02.050. Epub 2019 Apr  4."
        AB = "abstract",
        ID = 'id',
        DATE = 'date',
        CIT = 'citation'
    )
    nNewCitations <- 0
    nChangedCitations <- 0
    newPublications <- list()
    for(i in seq_along(d)){

        # read each line, i.e., PubMed tag, for this citation
        x <- list()
        ref <- strsplit(d[i], '\n')[[1]]
        for(line in ref){
            key <- trimws(substr(line, 1, 4))
            if(!(key %in% names(fields))) next
            contents <- substring(line, 7)
            if(is.absent(df[i, key])) df[i, key] <- contents
            else df[i, key] <- paste(df[i, key], contents, sep = "::")
        }

        # create modified fields consistent with publications.yml
        df[i, 'FA'] <- strsplit(df[i, 'AU'], " ")[[1]][1]
        df[i, 'YEAR'] <- substr(df[i, 'DP'], 1, 4)
        df[i, 'ID'] <- paste(df[i, 'FA'], df[i, 'YEAR'], sep = "_")
        DP <- strsplit(df[i, 'DP'], ' ')[[1]]
        mon0 <- match(DP[2], substr(month.name, 1, 3))
        if(is.absent(mon0)){
            mon00 <- '01'
            day00 <- '01'
        } else {
            mon00 <- sprintf('%02d', mon0)
            day00 <- if(is.absent(DP[3])) '01' else sprintf('%02d', as.integer(DP[3]))
        }
        df[i, 'DATE'] <- paste(df[i, 'YEAR'], mon00, day00, sep = "-")
        df[i, 'CIT'] <- if(is.absent(df[i, 'VI'])){
            x <- strsplit(df[i, 'SO'], '. doi')[[1]][1]
            strsplit(x, ':')[[1]][2]
        } else {
            issue <- if(is.absent(df[i, 'IP'])) '' else paste0('(', df[i, 'IP'], ')')
            pages <- if(is.absent(df[i, 'PG'])) '' else paste0(':', df[i, 'PG'])
            paste0(df[i, 'VI'], issue, pages)
        }    

        # assemble the incoming publication
        incoming <- list(
            id = df[i, 'ID'],
            date = df[i, 'DATE'],
            pmid = as.integer(df[i, 'PMID']),
            pmcid = df[i, 'PMC'],        
            authors = strsplit(df[i, 'AU'], '::')[[1]],
            title = naToNull( gsub('\\s+', ' ', substr(df[i, 'TI'], 1, nchar(df[i, 'TI']) - 1)) ),
            journal = df[i, 'TA'],
            citation = df[i, 'CIT'],
            year = as.integer(df[i, 'YEAR']),
            url = NULL,
            abstract = naToNull( df[i, 'AB'] ),
            badges = NULL
        )    

        # either import a new reference or update a prior reference based on incoming information
        if(df[i, 'PMID'] %in% names(pmids)){
            j <- pmids[[ df[i, 'PMID'] ]]
            citationChanged <- 0
            for(field in c('date', 'pmcid', 'authors', 'title', 
                        'journal', 'citation', 'year', 'abstract')){ # only some fields get overwritten
                old <- publications[[j]][[field]]
                new <- incoming[[field]]
                wasOld <- !is.absent(old)
                isNew <- !is.absent(new)
                if((!wasOld && isNew) ||
                   (wasOld && !isNew) ||
                   (wasOld && isNew && old != new)) citationChanged <- 1
                publications[[j]][[field]] <- new
            } 
            nChangedCitations <- nChangedCitations + citationChanged
        } else {
            nNewCitations <- nNewCitations + 1
            newPublications[[ length(newPublications) + 1 ]] <- 
                paste(incoming$year, paste(incoming$authors, collapse = ", "))
            publications[[ length(publications) + 1 ]] <- incoming
        }
    }

    # pass data to confirmation
    dates <- sapply(publications, function(x) x$date)
    confirmPubmedData(list(
        nNewCitations = nNewCitations,
        nChangedCitations = nChangedCitations,
        newPublications = newPublications,
        publications = publications[rev(order(dates))] # ensure newest comes at top of list
    ))
}

# get confirmation from the user
confirmPubmedImport <- function(){
    req(confirmPubmedData())
    d <- confirmPubmedData()
    nExisting <- length(config()$publications)
    tagList(
        tags$p(paste(d$nNewCitations,     "new references will be added to the site")),
        tags$p(paste(d$nChangedCitations, "of", nExisting, "existing references will be updated")),
        if(d$nNewCitations > 0) div(
            tags$p("The new references are:"),
            tags$ul(lapply(d$newPublications, tags$li))
        ) else "",
        actionButton('finishPubmedImport', "Yes, Finish the Import"),
        actionButton('clearPubmedImport', "Clear the Input Area")
    )
}

# finalize the import
observeEvent(input$finishPubmedImport, {
    req(input$finishPubmedImport)
    
    # write the new version of publication.yml; archive the prior version
    archiveFile <- paste0(rootDir, '/', '_data/_archive/publications-', Sys.Date(), '.yml')
    publicationsYml <- paste0(rootDir, '/', '_data/publications.yml')
    message(paste('archiving current _data/publications.yml to: ', archiveFile))
    file.copy(publicationsYml, archiveFile, overwrite = FALSE)
    message('writing new _data/publications.yml')
    write_yaml(confirmPubmedData()$publications, publicationsYml)   

    # update the site config and reset
    x <- config()
    x$publications <- confirmPubmedData()$publications
    config(x)
    updateTextAreaInput(session, 'pubmedImport', value = "")
})
observeEvent(input$clearPubmedImport, {
    req(input$clearPubmedImport)
    updateTextAreaInput(session, 'pubmedImport', value = "")
})

# List of 39
#  $ PMID: chr "30955886"
#  $ OWN : chr "NLM"
#  $ STAT: chr "MEDLINE"
#  $ DCOM: chr "20200302"
#  $ LR  : chr "20200502"
#  $ IS  : chr "0092-8674 (Linking)"
#  $ VI  : chr "177"
#  $ IP  : chr "4"
#  $ DP  : chr "2019 May 2"
#  $ TI  : chr "Genome-wide de novo L1 Retrotransposition Connects Endonuclease Activity with  Replication."
#  $ PG  : chr "837-851.e28"
#  $ LID : chr "10.1016/j.cell.2019.02.050 [doi]"
#  $ AB  : chr "L1 retrotransposon-derived sequences comprise approximately 17% of the 
# human genome.  Darwinian selective press"| __truncated__
#  $ CI  : chr "Copyright Ac 2019 Elsevier Inc. All rights reserved."
#  $ FAU : chr "Moran, John V"
#  $ AU  : chr "Moran JV"
#  $ AD  : chr "Department of Human Genetics, University of Mich"| __truncated__
#  $ LA  : chr "eng"
#  $ GR  : chr "IECS-55007420/HHMI/Howard Hughes Medical Institute/United States"      
#  $ PT  : chr "Research Support, Non-U.S. Gov't"
#  $ DEP : chr "20190404"
#  $ TA  : chr "Cell"
#  $ JT  : chr "Cell"
#  $ JID : chr "0413066"
#  $ RN  : chr "EC 3.1.- (Endonucleases)"
#  $ SB  : chr "IM"
#  $ MH  : chr "Retroelements/*genetics"
#  $ PMC : chr "PMC6558663"
#  $ MID : chr "NIHMS1523125"
#  $ OTO : chr "NOTNLM"
#  $ OT  : chr "*transposable element"
#  $ COIS: chr "DECLARATION OF INTERESTS JVM is an inventor on patent US6"| __truncated__
#  $ EDAT: chr "2019/04/09 06:00"
#  $ MHDA: chr "2020/03/03 06:00"
#  $ CRDT: chr "2019/04/09 06:00"
#  $ PHST: chr "2019/04/09 06:00 [entrez]"
#  $ AID : chr "10.1016/j.cell.2019.02.050 [doi]"
#  $ PST : chr "ppublish"
#  $ SO  : chr "Cell. 2019 May 2;177(4):837-851.e28. doi: 10.1016/j.cell.2019.02.050. Epub 2019 Apr  4."

choices <- reactive({
  rawData <- rawData()
  site_info <- rawData$chem_site
  choices <- c("All",site_info$`Short Name`)
  choices
})

observe({
  updateSelectInput(session, "sites", choices = choices())
})

epDF <- reactiveValues(assays = initAssay,
                       groupColName = "intended_target_family",
                       group = init_Groups,
                       flags = initFlags,
                       sites = "All",
                       fileName = "Choose file")

observeEvent(input$pickAssay, {
  epDF[["assays"]] <- NULL
  epDF[["assays"]] <- input$assay
  
})

observeEvent(input$pickFlags, {
  epDF[["flags"]] <- NULL
  epDF[["flags"]] <- input$flags
})

observeEvent(input$sites, {
  epDF[["sites"]] <- NULL
  epDF[["sites"]] <- input$sites
})

observeEvent(input$changeAnn, {
  epDF[["groupColName"]] <- NULL
  epDF[["groupColName"]] <- input$groupCol
  
})

observeEvent(input$allGroup, {
  epDF[["group"]] <- NULL
  epDF[["group"]] <- input$group
  
})

observeEvent(input$epGroup, {
  epDF[["epGroup"]] <- NULL
  epDF[["epGroup"]] <- input$epGroup
  
})

observe({
  
  if(!toxCast()){
    updateSelectInput(session, "sumEAR", selected = FALSE)
  }
  
})

observe({
  
  groupCol <- epDF[["groupColName"]]

  ep <- cleaned_ep
  orderBy <- ep[[groupCol]]
  orderNames <- names(table(orderBy))
  nEndPoints <- as.integer(table(orderBy))
  
  df <- data.frame(orderNames,nEndPoints,stringsAsFactors = FALSE) %>%
    dplyr::arrange(desc(nEndPoints))
  
  dropDownHeader <- c(paste0(df$orderNames," (",df$nEndPoints,")"))
  
  selChoices <- df$orderNames
  
  if(epDF[["groupColName"]] == "intended_target_family"){
    selChoices <- selChoices[!(selChoices %in% c("Background Measurement","Undefined"))]
  }
  epDF[["group"]] <- NULL
  epDF[["group"]] <- selChoices
  updateCheckboxGroupInput(session, "group", 
                           choices = setNames(df$orderNames,dropDownHeader),
                           selected = selChoices)
  
})

observe({
  labelText <- "Choose Chemical"
  
  if (input$radioMaxGroup == 2){
    labelText <- "Choose Chemical"
  } else if(input$radioMaxGroup == 3){
    labelText <- "Choose Class"
  } else if(input$radioMaxGroup == 1){
    labelText <- "Choose Group"
  }
  
  updateSelectInput(session, "epGroup", label = labelText)
})

chems <- reactive({
  chemical_summary <- chemical_summary()
  
  chem_no_zero <- chemical_summary %>% 
    dplyr::filter(EAR > 0) %>% 
    dplyr::select(chnm) %>% 
    dplyr::mutate(chnm = as.character(chnm)) %>% 
    dplyr::distinct() %>% 
    dplyr::pull(chnm)

  chems <- ""
  if(nrow(chemical_summary) > 0){
    chems <- levels(chemical_summary$chnm)[levels(chemical_summary$chnm) %in% chem_no_zero]
  }
  chems
})

classes <- reactive({
  chemical_summary <- chemical_summary()
  classes <- ""
  if(nrow(chemical_summary) > 0){
    classes <- levels(chemical_summary$Class)
  }
  classes
})

Bio_category <- reactive({
  chemical_summary <- chemical_summary()
  Bio_category <- ""
  if(nrow(chemical_summary) > 0){
    Bio_category <- unique(chemical_summary$Bio_category)
  }
  
  Bio_category
})


observe({

  valueText <- "All"

  if (input$radioMaxGroup == 2){
    valueText <- c("All", rev(c(chems())))
    first_pick <- rev(c(chems()))[1]
  } else if(input$radioMaxGroup == 3){
    valueText <- c("All", classes())
    first_pick <- classes()[1]
  } else if(input$radioMaxGroup == 1){
    valueText <- c("All", Bio_category())
    first_pick <- Bio_category()[1]
  }

  updateSelectInput(session, "epGroup", choices = valueText, selected = first_pick)
})

## Everything in this file and any files in the R directory are sourced during `simInit()`;
## all functions and objects are put into the `simList`.
## To use objects, use `sim$xxx` (they are globally available to all modules).
## Functions can be used inside any function that was sourced in this module;
## they are namespaced to the module, just like functions in R packages.
## If exact location is required, functions will be: `sim$.mods$<moduleName>$FunctionName`.
defineModule(sim, list(
  name = "Quebec_fires_preamble",
  description = "",
  keywords = "",
  authors = structure(list(list(given = c("First", "Middle"), family = "Last",
                                role = c("aut", "cre"), email = "email@example.com", comment = NULL)), class = "person"),
  childModules = character(0),
  version = list(Quebec_fires_preamble = "0.0.0.9000"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list("citation.bib"),
  documentation = list("README.md", "Quebec_fires_preamble.Rmd"), ## same file
  reqdPkgs = list("PredictiveEcology/SpaDES.core@development (>=1.0.10.9002)",
                  "fasterize", "sf" ,"raster", "ggplot2", "PredictiveEcology/climateData",
                  "PredictiveEcology/LandR@development"),
  parameters = rbind(
    #defineParameter("paramName", "paramClass", value, min, max, "parameter description"),
    defineParameter(".plots", "character", "screen", NA, NA,
                    "Used by Plots function, which can be optionally used here"),
    defineParameter(".plotInitialTime", "numeric", start(sim), NA, NA,
                    "Describes the simulation time at which the first plot event should occur."),
    defineParameter(".plotInterval", "numeric", NA, NA, NA,
                    "Describes the simulation time interval between plot events."),
    defineParameter(".saveInitialTime", "numeric", NA, NA, NA,
                    "Describes the simulation time at which the first save event should occur."),
    defineParameter(".saveInterval", "numeric", NA, NA, NA,
                    "This describes the simulation time interval between save events."),
    ## .seed is optional: `list('init' = 123)` will `set.seed(123)` for the `init` event only.
    defineParameter(".seed", "list", list(), NA, NA,
                    "Named list of seeds to use for each event (names)."),
    defineParameter(".useCache", "logical", FALSE, NA, NA,
                    "Should caching of events or module be used?")
  ),
  inputObjects = bindrows(
    #expectsInput("objectName", "objectClass", "input object description", sourceURL, ...),
    expectsInput(objectName = "studyArea", objectClass = "sf", desc = NA, sourceURL = NA),
    expectsInput(objectName = "rasterToMatch", objectClass = "rasterLayer", desc = NA, sourceURL = NA),
  ),
  outputObjects = bindrows(
    #createsOutput("objectName", "objectClass", "output object description", ...),
    createsOutput(objectName = "sppEquiv", objectClass = "data.table", desc = NA),
    createsOutput(objectName = "sppColors", objectClass = "character", desc = NA)
  )
))

## event types
#   - type `init` is required for initialization

doEvent.Quebec_fires_preamble = function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {
      ### check for more detailed object dependencies:
      ### (use `checkObject` or similar)

      # do stuff for this event
      sim <- Init(sim)

      # schedule future event(s)
      sim <- scheduleEvent(sim, P(sim)$.plotInitialTime, "Quebec_fires_preamble", "plot")
      sim <- scheduleEvent(sim, P(sim)$.saveInitialTime, "Quebec_fires_preamble", "save")
    },
    plot = {
      # ! ----- EDIT BELOW ----- ! #
      # do stuff for this event

      plotFun(sim) # example of a plotting function
      # schedule future event(s)

      # e.g.,
      #sim <- scheduleEvent(sim, time(sim) + P(sim)$.plotInterval, "Quebec_fires_preamble", "plot")

      # ! ----- STOP EDITING ----- ! #
    },
    save = {},
    event1 = {
      # ! ----- EDIT BELOW ----- ! #
      # do stuff for this event

      # e.g., call your custom functions/methods here
      # you can define your own methods below this `doEvent` function

      # schedule future event(s)

      # e.g.,
      # sim <- scheduleEvent(sim, time(sim) + increment, "Quebec_fires_preamble", "templateEvent")

      # ! ----- STOP EDITING ----- ! #
    },
    warning(paste("Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
                  "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""))
  )
  return(invisible(sim))
}

## event functions
#   - keep event functions short and clean, modularize by calling subroutines from section below.

### template initialization
Init <- function(sim) {

  sim$sppEquiv <- LandR::sppEquivalencies_CA
  sim$sppEquiv <- sim$sppEquiv[LandR %in% c("Abie_bal", "Pice_mar",
                                            "Pinu_ban", "Lari_lar",
                                            "Pice_gla", "Betu_pap",
                                            "Popu_tre"),]
  sim$sppColors <- LandR::sppColors(sppEquiv = sim$sppEquiv, sppEquivCol = "LandR", palette = "Accent")
  return(invisible(sim))
}

### template for save events
Save <- function(sim) {
  # ! ----- EDIT BELOW ----- ! #
  # do stuff for this event
  sim <- saveFiles(sim)

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

### template for plot events
plotFun <- function(sim) {
  # ! ----- EDIT BELOW ----- ! #
  # do stuff for this event
  sampleData <- data.frame("TheSample" = sample(1:10, replace = TRUE))
  Plots(sampleData, fn = ggplotFn)

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

### template for your event1
Event1 <- function(sim) {
  # ! ----- EDIT BELOW ----- ! #
  # THE NEXT TWO LINES ARE FOR DUMMY UNIT TESTS; CHANGE OR DELETE THEM.
  # sim$event1Test1 <- " this is test for event 1. " # for dummy unit test
  # sim$event1Test2 <- 999 # for dummy unit test

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

### template for your event2
Event2 <- function(sim) {
  # ! ----- EDIT BELOW ----- ! #
  # THE NEXT TWO LINES ARE FOR DUMMY UNIT TESTS; CHANGE OR DELETE THEM.
  # sim$event2Test1 <- " this is test for event 2. " # for dummy unit test
  # sim$event2Test2 <- 777  # for dummy unit test

  # ! ----- STOP EDITING ----- ! #
  return(invisible(sim))
}

.inputObjects <- function(sim) {

  #cacheTags <- c(currentModule(sim), "function:.inputObjects") ## uncomment this if Cache is being used
  dPath <- file.path('modules', currentModule(sim), "data")
  message(currentModule(sim), ": using dataPath '", dPath, "'.")

  if (!suppliedElsewhere("studyArea", sim)){
    sim$studyArea <- prepInputs(url = "https://drive.google.com/file/d/1OYWKXv3OciReK8PhQY0E7sFL5A-u3P6L/view?usp=sharing",
                                destinationPath = dPath)
  }
  if (!suppliedElsewhere("rasterToMatch", sim)) {

    sim$rasterToMatch <- Cache(prepInputsLCC,
                               year = 2010,
                               destinationPath = dPath,
                               studyArea = sim$studyArea)
    sim$rasterToMatch <- Cache(projectRaster,
                               sim$rasterToMatch,
                               crs = crs(sim$rasterToMatch),
                               res = c(250, 250), method = "ngb",
                               filename = file.path(dPath, "guillaumeRTM.tif"),
                               overwrite = TRUE)
    sim$studyArea <- st_transform(sim$studyArea, crs = crs(sim$rasterToMatch))

  }

  return(invisible(sim))
}

ggplotFn <- function(data, ...) {
  ggplot(data, aes(TheSample)) +
    geom_histogram(...)
}

### add additional events as needed by copy/pasting from above
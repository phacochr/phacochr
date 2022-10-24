
# global
library(shiny)
library(fuzzyjoin) # Package pour faire des jointures probabilistes
library(stringdist) # Mesures de distance entre chaînes de caractères
library(readxl) # Pour lire des fichiers excel
library(sf) # Package de SIG
library(tmap) # Package de carto 
library(mapsf) # Package de carto
library(tidyverse) # Ensemble de fonctions pour manipuler une base de données
library(doParallel) # Pour du calcul multicores
library(foreach) # Pour du calcul multicores
library(gt) # Pour l'output HTML si adresse solo


#source("Script géocodage/Script de géocodage parallel.R")

options (shiny.maxRequestSize=300*1024^2) 
# ui

foo <- function() {
  message("one")
  Sys.sleep(0.5)
  message("two")
}



ui <- navbarPage(title = "Phacoch-R",
                 # PAGE IMPORTATION DES DONNÉES
                 tabPanel(title = "Importation des données",
                          fluidPage(
                            # Sidebar layout with input and output definitions ----
                            sidebarLayout(
                              
                              # Sidebar panel for inputs ----
                              sidebarPanel(
                                
                                # Choisir le format du fichier en entrée
                                radioButtons(
                                  "fileType_Input",
                                  label = "Type de fichier à géocoder",
                                  choices = list(".csv" = 1, ".xlsx" = 2),
                                  selected = 1,
                                  inline = TRUE
                                ),
                                
                                # Input: Select a file ----
                                fileInput("file1", "Fichier à géocoder (max 300 MB)",
                                          multiple = TRUE,
                                          accept = c('text/csv',
                                                     'text/comma-separated-values,text/plain',
                                                     '.csv',
                                                     '.xlsx')),
                                
                                # Horizontal line ----
                                #tags$hr(),
                                
                                # Input: Checkbox if file has header ----
                                checkboxInput("header", "Entête (header)", TRUE),
                                
                                # Input: Select separator ----
                                radioButtons("sep", "Separateur de champs",
                                             choices = c(`,` = ",",
                                                         `;` = ";",
                                                         `|` = "|",
                                                         Tab = "\t",
                                                         `~` = "~"),
                                             selected = ";",
                                             inline= T),
                                
                                # Input: Select quotes ----
                                radioButtons("quote", "Guillement pour les champs texte",
                                             choices = c("Pas de guillemet" = "",
                                                         `Doubles guillements ( "  " )` = '"',
                                                         "Simples guillements ( '  ' )" = "'"),
                                             selected = "")
                              ),
                              
                              # Main panel for displaying outputs ----
                              mainPanel(
                                h4("Aperçu des données à géocoder"),
                                # Output: Data file ----
                                tableOutput("head_data_to_geocode")
                                
                              )
                              
                            )
                          )),
                 # PAGE GEOCODAGE
                 tabPanel(title = "Géocodage",
                          fluidPage(
                            # Sidebar layout with input and output definitions ----
                            sidebarLayout(
                              
                              # Sidebar panel for inputs ----
                              sidebarPanel(
                                # Input: Select variables ---- 
                                selectInput(inputId = "colonne_rue", label = "Rue", choices = NULL),
                                selectInput(inputId = "colonne_num_rue", label = "Numéro", choices = NULL),
                                selectInput(inputId = "colonne_code_postal", label = "Code postal", choices = NULL),
                                
                                # Horizontal line ----
                                tags$hr(),
                                # Input: Select méthode ----
                                radioButtons("method_stringdist", "Méthode",
                                             choices = c(lcs = "lcs"),
                                             selected = "lcs"),
                                # Input: Nombre d'erreur ----
                                numericInput(inputId = "error_max",
                                             label = "Nombre d'erreur maximum acceptées par la jointure probabiliste (conseillé : 2-4)",
                                             value = 4),
                                # Input: Approximation numéro ----
                                numericInput(inputId = "approx_num",
                                             label = "Approximation maximale autorisée pour la géolocalisation du batiment - en nombre de numéros à gauche ou à droite",
                                             value = 50),
                                # Input: Select langue ----
                                radioButtons("lang_encoded", "Langue des adresses (augmente la rapidité du goécodage)",
                                             choices = c("FR-NL-DE"="FR-NL-DE","FR" = "FR", "NL"="NL"),
                                             selected = "FR-NL-DE"),
                                # Input: corrections orthographiques ----
                                checkboxInput("corrections_REGEX", "Correction orthographique des adresses", TRUE),
                                # Input: corrections orthographiques ----
                                checkboxInput("preloading_RAM", "Chargement de tous les fichiers dans la RAM", FALSE),
                                # Input: corrections orthographiques ----
                                checkboxInput("benchmarking_time", "Suivi du temps écoulé pour chacune des étapes", TRUE),
                                # Input: corrections orthographiques ----
                                checkboxInput("elargissement_com_adj", "Elargir la recherche des rues non trouvées aux communes adjacentes", TRUE),
                                # Horizontal line ----
                                tags$hr(),
                                actionButton("geocode", "Lancer le géocodage"),
                                
                              ),
                              # Main panel for displaying outputs ----
                              mainPanel(
                                shinyjs::useShinyjs(),
                                h4("Résumé du géocodage"),
                                # Output: Data file ---- Summary_full
                                shinycssloaders::withSpinner(tableOutput("Summary_full"),type = 3, color = "#636363", color.background ="#ffffff", size = 0.8),
                                textOutput("text")
                              )))),
                 tabPanel(title = "Cartes",
                          fluidPage(
                            shinycssloaders::withSpinner(tmapOutput(outputId = "tmapMap", width = "100%", height = 800)
                                                         ,type = 3, color = "#636363", color.background ="#ffffff", size = 0.8)    
                            
                              )),
                 tabPanel(title = "Export",
                          fluidPage(
                            # Sidebar layout with input and output definitions ----
                            sidebarLayout(
                              
                              # Sidebar panel for inputs ----
                              sidebarPanel(
                                radioButtons(
                                  "fileType_output",
                                  label = "Extension du fichier",
                                  choices = list(".csv" = ".csv", 
                                                 #".xlsx" = ".xlsx",
                                                 ".gpkg"=".gpkg",
                                                 ".kml"= ".kml",
                                                 ".geojson"=".geojson"
                                  ),
                                  selected = ".csv",
                                  inline = TRUE
                                ),
                                downloadButton("downloadData", "Télécharger le fichier géocodé")
                                
                              ),
                              # Main panel for displaying outputs ----
                              mainPanel(
                                h4("Aperçu des données géocodées"),
                                # Output: Data file ---- Summary_full
                                shinycssloaders::withSpinner(tableOutput("head_FULL_GEOCODING")
                                                             ,type = 3, color = "#636363", color.background ="#ffffff", size = 0.8)   
                                                              )))),
                 
)

# Define server logic to read selected file ----
server <- function(input, output, session) {
  # PAGE 1 : IMPORTATION ET AFFICHAGE
  # importation des données
  data_to_geocode<- reactive({
    req(input$file1)
    if(input$fileType_Input == 1) {read_delim(input$file1$datapath, delim = input$sep,quote = input$quote,trim_ws = TRUE)}
    else{read_excel(input$file1$datapath,col_types= "text")}})
  
  # Affichage des premières lignes
  output$head_data_to_geocode <- renderTable({
    req(input$file1)
    head(data_to_geocode())})
  
  # PAGE 2 : GÉOCODAGE
  # Sélectionne les variables à choisir pour l'adresse
  observe({ updateSelectInput(session, "colonne_rue", choices = c("-", names(data_to_geocode()))) }) 
  observe({ updateSelectInput(session, 'colonne_num_rue', choices = c("-",names(data_to_geocode()))) }) 
  observe({ updateSelectInput(session, 'colonne_code_postal', choices = c("-",names(data_to_geocode()))) })   
  # Lancer le géocodage
  
  
  phacochr <- eventReactive(input$geocode, {
    # pour l'affichage des messages en html
    withCallingHandlers({
      shinyjs::html("text", "")
      # création des objets comme dans le code .R
      colonne_rue=input$colonne_rue
      num_rue<- ifelse(input$colonne_num_rue=="-", "int", "sep")
      colonne_num_rue <- input$colonne_num_rue
      code_postal<- ifelse(input$colonne_code_postal=="-", "int", "sep")
      colonne_code_postal <-input$colonne_code_postal
      method_stringdist<-input$method_stringdist  
      corrections_REGEX<- input$corrections_REGEX
      error_max<-input$error_max
      approx_num<-input$approx_num
      elargissement_com_adj<- input$elargissement_com_adj 
      preloading_RAM<-FALSE
      benchmarking_time<-input$benchmarking_time
      lang_encoded<-input$lang_encoded
      choice_lang<-ifelse(input$lang_encoded=="FR-NL-DE", FALSE, TRUE)
      data_to_geocode<-data_to_geocode()
      # lancement du script
      source("Script géocodage/Script de géocodage parallel_HUGO.R", local=TRUE)
      phacochr }
      ,
      #affichage des messages à la ligne
      message = function(m) {shinyjs::html(id = "text", html = paste0(m$message, '<br>'), add = TRUE)})
  })
  
  # Affichage des tableau récap
  output$Summary_full <-  renderTable({
    req(input$geocode)
    phacochr()$Summary_full
  })
  
  # Affichage des données géocodées
  output$head_FULL_GEOCODING <-  renderTable({
    req(input$geocode)
    head(phacochr()$FULL_GEOCODING)
  })
  

  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$file1$name, "_phacochr", input$fileType_output)
    },
    content = function(file) {
      if(input$fileType_output == ".csv") {
        write.csv(phacochr()$FULL_GEOCODING, file, row.names = FALSE)
      } else if(input$fileType_output %in%c(".gpkg",".kml",".geojson")) {
        st_write(phacochr()$FULL_GEOCODING_sf, file)
      }
    })
  
  
  
  output$tmapMap <- renderTmap({
    req(phacochr()$FULL_GEOCODING_sf)
    FULL_GEOCODING_sf<-  phacochr()$FULL_GEOCODING_sf
    name_to_show <- "nom"
    title_carto = ""
    
    zoom_geocoded <- FALSE
    nom_admin <- TRUE
        source("Script géocodage/Carto des points géocodés - tmap interactif.R", local=TRUE)
    Carto_map
    
  })
  
  
}

# Create Shiny app ----
shinyApp(ui, server )
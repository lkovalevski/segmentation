#' ---
#' title: Descriptive Analysis for BCRA dataset
#' author: Kovalevski, L.
#' date: April, 2024 
#' toctitle: "Tabla de Contenidos"
#' output: 
#'   bookdown::html_document2:
#'     toc: TRUE
#'     toc_float: true
#'     toc_depth: 2
#'     code_folding: hide
#'     df_print: paged
#'     theme: united
#' ---


#' 
#' 
#' -----------------
#' 
#' 
#' 
#' 

#' #  Executive summary {-}


#' 
#' 
#' - to be completed..
#' - 
#'  
#' 



# ---------------------------------------------------
#' # Run Info {-}
#' 
#' 
file_name <- "df_bcra.rds"

#' 
#' This report was run with the **objetive** of describing the bcra dataset: \n
#' 
#' -  **Run date**  :`r  Sys.Date()` \n
#' -  **Dataset **  :`r  file_name`  \n
#' 
#' 



#' # Dataset description.



#'  The database consists of a random sample of 23,857 tax identification numbers (CUITs) belonging to individuals who had at least one debt in the Argentine financial system in June 2019, and were in credit situation 1 or 2 (meaning they did not have overdue payments exceeding 90 days), obtained from the debtor database provided by the Central Bank of the Argentine Republic (BCRA) for the period of June 2019.
#'  For the tax identification numbers in the random sample, debts in all entities were recorded and summarized for June 2019, as well as for the previous 6 months. Debts of these tax identification numbers between July 2019 and June 2020 were also recorded to assess their evolution. 
#'  The response variable is a binary variable constructed from the most severe credit situation of the tax identification number (CUIT) between the periods of July 2019 and June 2020. The variable takes the value 1 if the most severe credit situation is greater than or equal to 3 in any debt any period, and 0 otherwise.
#'  In the dataset 'df_bcra.rds', the information recorded with 28 variables is available. The data is anonymized and variable names are not displayed.
#'  


#' ## Load data and needed packages.

#' Install (if needed)  'here' package to use relative paths. 
if(!("here" %in% installed.packages()[, "Package"])){ 
  install.packages("here") 
  }

#' Load generic functions ----
source(here::here("src", "utils.R"), encoding = "UTF-8")

#' Cargar las librerías necesarias
loadPackages(c(
  "here", "multiview", "ggplot2", "knitr", "scales", "dplyr", "doBy", "moments",
  "gains", "ROCR", "skimr", "moments", "corrplot"
  ))

#' Set data path
file_path <- here::here("data", "ready")



#' Set data file names
if( !exists("file_name") ){
  file_name <- "df_bcra.rds"
}

#' read data
df <- readRDS(file.path(file_path, file_name))


#' ## General descriptive analysis.

skim(df)


#' ## Response descriptive analysis.

#' 
#' 
#' To analyze the default, we use the variable: **'response'**, which take the
#' following values: \n
#' 
#' -  **0**: if the most severe credit situation is always less than 3 (always 
#' the payment delay is less than 90 days). \n
#' -  **1**: if the most severe credit situation is greater than or equal to 3 
#' in any debt any period. \n
#' 
#'

response <- "response"

cat(paste0("\n### Response variabe: **", response, "**.\n"))

describeCategorical(
  data         = df,
  var          = response,
  bar_color    = "#fff159" 
  ) 


cat("\n")
cat("\n")





#' ## Descriptive analysis of categorical predictors

#' Identify categorical and quantitavie variables
nvars <- names(df)[(sapply(X = df, FUN = class)) %in% 
                     c("integer", "numeric", "double") ]
cvars <- names(df)[(sapply(X = df, FUN = class)) %in% 
                     c("character", "factor", "logical", "text") ]

for (var in cvars){
  
  describeCategoricalAndBinary(
    data    = df, 
    var     = var, 
    binary  = response,
    ti      = which(cvars == var), 
    gi      = which(cvars == var)
    )
}




#' ## Descriptive analysis of quantitative predictors

vars_to_exclude <- c( response, "id" )
nvars              <- nvars[!nvars %in% vars_to_exclude]


for (var in nvars){

  describeNumericAndBinaryResponse(
    data             = df, 
    var              = var, 
    binary        = response,
    ti               = which(cvars == var), 
    gi               = which(cvars == var), 
    )
}



# ---------------------------------------------------
writeText("\n### Asociation analysis - Quantitative predictors")


cat("\n")
cat("\n")
cat(paste0("\n### * Matriz de correlaciones.* \n"))
cat("\n")
cat("\n")

# Correlaciones de a pares
M      <- cor(df[, nvars], use = "pairwise.complete.obs")
df_cor <- cor(df[, nvars])
corrplot(df_cor, order = 'hclust', addrect = 5)


# Cooperative Learning
Leandro Kovalevski

- [Executive summary](#executive-summary)
- [Settings](#settings)
- [<span class="toc-section-number">1</span> Dataset
  description.](#dataset-description.)

# Executive summary

- to be completed..
- …
- …

# Settings

<details>
<summary>Show the code</summary>

``` r
file_name <- "df_bcra.rds"
```

</details>

This report was run with the **objetive** of describing the bcra
dataset:

- **Run date** :2024-06-12

- **Dataset ** :df_bcra.rds

# Dataset description.

The database consists of a random sample of 23,857 tax identification
numbers (CUITs) belonging to individuals who had at least one debt in
the Argentine financial system in June 2019, and were in credit
situation 1 or 2 (meaning they did not have overdue payments exceeding
90 days), obtained from the debtor database provided by the Central Bank
of the Argentine Republic (BCRA) for the period of June 2019. For the
tax identification numbers in the random sample, debts in all entities
were recorded and summarized for June 2019, as well as for the previous
6 months. Debts of these tax identification numbers between July 2019
and June 2020 were also recorded to assess their evolution. The response
variable is a binary variable constructed from the most severe credit
situation of the tax identification number (CUIT) between the periods of
July 2019 and June 2020. The variable takes the value 1 if the most
severe credit situation is greater than or equal to 3 in any debt any
period, and 0 otherwise. In the dataset ‘df_bcra.rds’, the information
recorded with 28 variables is available. The data is anonymized and
variable names are not displayed.

<details>
<summary>Show the code</summary>

``` r
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
```

</details>

    Warning: package 'ggplot2' was built under R version 4.3.3

    Warning: package 'knitr' was built under R version 4.3.3

    Warning: package 'scales' was built under R version 4.3.3

    Warning: package 'dplyr' was built under R version 4.3.3

    Warning: package 'doBy' was built under R version 4.3.3

    Warning: package 'ROCR' was built under R version 4.3.1

    Warning: package 'skimr' was built under R version 4.3.1

    Warning: package 'corrplot' was built under R version 4.3.1

<details>
<summary>Show the code</summary>

``` r
#' Set data path
file_path <- here::here("data", "ready")
```

</details>

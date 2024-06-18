#'#############################################################################
#' 
#' Generic functions
#' =============================================
#'
#' 
#'
#'   
#'   
#'#############################################################################

loadPackages <- function(pckgs) {
  # Load required packages, installing those not already installed.
  #
  # Arguments:
  #   pckgs: vector with package names.
  #
  # Args:
  #   pckgs (vector): A character vector of package names.
  #
  # Returns:
  #   None
  new.packages <- pckgs[!(pckgs %in% installed.packages()[, "Package"])]
  if (length(new.packages) > 0) {
    install.packages(new.packages)
  }
  for (pckg in pckgs) {
    suppressPackageStartupMessages(
      suppressWarnings(
        library(pckg, character.only = TRUE)
      ))
  }
}


writeText <- function(text_to_print, logname = NULL) { 
  #' Print the specified text in the console and simultaneously (if a log file is specified)
  #' document the text in the indicated '.log' file.
  #' 
  #' Arguments: 
  #'   text_to_print: Character string to be saved.
  #'   logname      : Name of the .log file where the strings are saved.
  #'                  (by default, it is null and only the text is printed in the console)
  #' 
  cat(text_to_print)
  if (!is.null(logname)) {
    cat(text_to_print, file = logname, sep = "\n")
  }
}



describeCategorical <- function(
    data, var, ti = 1, gi = 1, 
    ordinals     = NULL,
    plot         = TRUE,
    bar_color    = "#046a38",
    row_name     = "records",
    logname_eda  = NULL,
    min_cat      = 15,
    min_grouping = 10
) {
  #' Calculate frequency and percentages for different levels of variable "var" 
  #' in dataset "data" and display them in table and graph.
  #' 
  #' Arguments: 
  #'   data:         Data frame to use.
  #'   var:          Variable to analyze.
  #'   ti:           (default value: 1)
  #'   gi:           (default value: 1)  
  #'   ordinals:     (default value: NULL)
  #'   plot:         Indicates whether to create plots 
  #'                 (default value: TRUE)
  #'   bar_color:    (default value: "#046a38" )
  #'   row_name:     Name to use for the analyzed individuals
  #'                 ("records")
  #'   logname_eda:  File where interpretations are to be saved
  #'                 (default value: NULL)
  #'   min_cat:      Minimum categories to re-group
  #'                 (default value: 15)
  #'   min_grouping: Minimum observations required for a category 
  #'                 to not be re-grouped.
  #'                 (default value: 10)            
  #'   
  #' Dependencies on packages: "ggplot2"
  #' Dependencies on functions: "write"  
  #' 
  
  require(ggplot2)
  require(dplyr)
  
  #' Convert variable to factor to retain NA values.
  data <- data %>% mutate(!!var := factor(get(var), exclude = NULL))
  
  if (nrow(distinct(data[var])) > min_cat) {
    # Group categories with fewer than 6 observations, only if the variable
    # has more than 8 categories in total
    data <- group_levels(data = data, var = var, min_obs = min_grouping)  
    cat(paste0(
      "\nFor this variable, categories with ", min_grouping,
      " or fewer observations are grouped as 'Others'.\n"
    ))
  }
  
  # Create the table
  t  <- table(data[var])
  p  <- prop.table(t)
  t1 <- data.frame(levels  = rownames(t), cbind(t, p)) 
  
  colnames(t1) <- c(var, paste0("Count ", row_name), "Percentage")
  
  # Create an ordered table
  t_ord <- t1 %>% arrange( - Percentage) %>% 
    mutate(Percentage = as.factor(sprintf("%3.1f%%", 100 * Percentage)))
  
  # Sort by frequency for non-ordinal variables  
  if (! var %in% ordinals) {
    t1 <- t_ord 
  } else {
    t1 <- t1 %>% 
      mutate(Percentage = as.factor(sprintf("%3.1f%%", 100 * Percentage)))
  }
  
  # Update table index
  if (!exists("sec")) { sec <- 1 }
  tindex <- paste0(sec, ".", ti) 
  
  # Comment on the top 3 percentage of the most frequent category
  text <- 
    paste0("\nAnalyzing the most frequent values of '", var, "' reveals that ", 
           t_ord[1, paste0("Count ", row_name)], " (", 
           t_ord[1, "Percentage"], ") of ", row_name," have '", var, 
           "' equal to '*", t_ord[1, var], "*', while ", 
           t_ord[2, "Percentage"], " have '", var, "' equal to '*", 
           t_ord[2, var], "*'")
  
  if (nrow(t_ord) >= 3) {
    text <- 
      paste0(text, ", and ", t_ord[3, "Percentage"], " have '", var,
             "' equal to '*", t_ord[3, var], "*' (Table ", tindex,"). \n")
  } else { text <-  paste0(text, " (Table ", tindex,"). \n") }
  
  
  writeText(text, logname = logname_eda)
  
  row_name_short = row_name
  
  title_table <- paste0("\n### Table ", tindex,". Count and percentage of ", 
                        row_name_short, " by '", var,  "'. {-} ")
  
  cat("\n")  
  cat("\n")
  cat(title_table)
  ti <- 1 + ti
  
  cat("\n")  
  cat("\n")
  print(knitr::kable(t1, row.names = FALSE, align = c('l', 'r', 'r')))
  
  cat("\n")
  
  if (plot == TRUE) {
    gt <- ggplot(t1, aes(x = factor(get(var), levels = rev(t1[, 1])), 
                         y = t1[, 2] / sum(t1[, 2]))) + 
      geom_bar(stat = "identity", fill = bar_color) + 
      scale_fill_manual("") +
      scale_x_discrete(name = paste(var)) + 
      scale_y_continuous(name = "Percentage", labels = scales::percent) + 
      theme_bw() +   
      coord_flip() + 
      geom_hline(yintercept = 0, color = "grey", size = .5) +
      theme(panel.border = element_blank(),  
            panel.grid.minor   = element_blank(), 
            panel.background   = element_blank(),
            axis.text.y        = element_text(size = rel(1.5)),
            axis.text.x        = element_text(size = rel(1.5)),
            axis.title.x       = element_text(size = rel(1.3)),
            axis.title.y       = element_text(size = rel(1.3))
      )
    
    
    gindex <- paste0(sec, ".", gi) # Update graph index
    
    cat(paste0("\n### Figure ", gindex, ". Percentage of ", row_name_short,
               " by ", var, ". {-} \n"))
    gi <- 1 + gi
    
    print(gt)
    
    cat("\n")
    cat("\n")
  }
}



describeCategoricalAndBinary <- function(
    data, var, binary, 
    ti = 1, gi = 1, 
    ordinals        = NULL,
    plot            = TRUE,
    bar_color       = "#006AA7",
    line_color1     = "#fff159",
    line_color2     = "#00bbfe", 
    row_name        = "records",
    save_plots      = FALSE,
    ini_time        = NULL,
    logname_eda     = NULL,
    min_cat         = 15
) {
  #' Calculate frequency and percentages for the different levels of variable 
  #' "var" in dataset "data" and display them in table and graph.
  #' 
  #' Arguments: 
  #'   data:             Data frame to use.
  #'   var:              Variable to analyze.
  #'   binary:         binary variable to analyze.
  #'   ti:               (default value: 1)
  #'   gi:               (default value: 1)  
  #'   ordinals:         (default value: NULL)
  #'   plot:             Indicates whether to create plots 
  #'                     (default value: TRUE)
  #'   bar_color:        (default value: "#0b0080" (Blue MP))
  #'   line_color1:      (default value: "#00bbfe" (Light blue MP)) or "#fff159" (Yellow ML))
  #'   line_color2:      (default value: "#fff159" (Yellow ML))
  #'   row_name:         Name to use for the analyzed individuals
  #'                     (default value: "records")
  #'   save_plots:       Indicates whether to save the plots
  #'                     (default value: FALSE)
  #'   ini_time:         Identifier for date and time to save the names
  #'                     of the graphs to be saved.
  #'                     (default value: NULL)
  #'   logname_eda:      File where interpretations are to be saved
  #'                     (default value: NULL) 
  #'   min_cat:          Minimum categories to re-group
  #'                     (default value: 15)                                
  #'   
  #' Dependencies on packages: "ggplot2" (version 3.3.0 for using
  #' the function guide_axis() )
  #' Dependencies on function: "writeText" 
  
  require(knitr)
  require(ggplot2)
  require(doBy)
  require(moments)
  
  writeText(paste0("\n### Variable: **", var, "**. {-} \n"))
  
  #' Convert variable to factor to retain NA values.
  data <- data %>% mutate(!!var := factor(get(var), exclude = NULL))
  
  if(nrow(distinct(data[var])) > min_cat){
    # Group categories with fewer than 6 observations, only if the variable
    # has more than 8 categories in total
    data <- group_levels(data = data, var = var, min_obs = 5)  
    cat(paste0(
      "\nFor this variable, categories with 5 or fewer ",
      "observations are grouped as 'Others'.\n"
    ))
  }
  
  result <- data.frame(
    data  %>% 
      dplyr::group_by(!!var := get(var)) %>% 
      dplyr::summarize(
        n             = n(), 
        !!binary    := mean(get(binary), na.rm = TRUE)
      ) %>% 
      dplyr::mutate( 
        percentage       = round(100 * n / sum(n), 1),
        `n (percentage %)` = paste0(n, " (", sprintf("%3.1f%%",percentage), ")") ),
    check.names = FALSE  ) 
  
  # Sort the table to find the most frequent ones
  t_ord <- result %>% arrange( - n )  %>% 
    mutate(percentage = as.factor(sprintf("%3.1f%%", percentage)))
  
  # Comment on the top 3 percentage of the most frequent category
  # Update the table index
  if( !exists("sec") ){ sec <- 1 }
  tindex <- paste0(sec, ".", ti) 
  
  text <- 
    paste0("\nAnalyzing the most frequent values of '", var, "' reveals",
           " that ", t_ord[1, "n"], " (", t_ord[1, "percentage"], ") of ", 
           row_name," have '", var, "' equal to '*", t_ord[1, var], "*',",
           " while ", t_ord[2, "percentage"], " have '", var, 
           "' equal to '*", t_ord[2, var], "*'")
  
  if(nrow(t_ord) >= 3){
    text <- 
      paste0(text, ", and ", t_ord[3, "percentage"], " have '", var,
             "' equal to '*", t_ord[3, var], "*' (Table ", tindex,"). \n")
  } else{ text <-  paste0(text, " (Table ", tindex,"). \n") }
  
  writeText(text, logname = logname_eda)
  
  t_ord2 <- result %>% arrange(- get(binary)) %>% 
    mutate(!!binary := as.factor(sprintf("%3.1f%%", 100 * get(binary))))
  
  text2 <- 
    paste0("\n**The highest percentage of '", binary, "' is for '*", 
           t_ord2[1, var], "*' with: ", t_ord2[1, binary], "**. The ",
           "next highest percentage is for: '*", t_ord2[2, var], 
           "*', with: ", t_ord2[2, binary], " (Table ", tindex,"). \n")  
  
  writeText(text2, logname = logname_eda)
  
  
  row_name_short <- substr(row_name, 5, nchar(row_name))
  
  tit_table <- paste0(
    "\n### Table ", tindex,". Count (and percentage) of ", row_name_short, 
    " and proportion of events for '", binary,
    "' by '",  var,  "'. {-}")
  
  cat(tit_table)
  ti <- 1 + ti
  
  print(kable(result[, c(paste0(var), "n (percentage %)", 
                         paste0(binary))],
              row.names = FALSE, align = c('l', 'r','r', 'r'),
              digits = 3))
  
  cat("\n")
  
  
  if(plot){ 
    # Relation between the different quantities in the graphs
    r <- max(result$n) / max(result[, 3])
    
    label <- structure(c(bar_color, line_color2, line_color1), 
                       .Names = c("Frequency", binary))
    
    # Rotate the labels of the x-axis when the variable has more than 5 
    # categories with more than 15 characters
    #TODO: check the following syntax:
    # rotate_x_labels <- sum(1 * ( nchar(result[,var]) > 15 )) > 5
    rotate_x_labels <- var %in% c("producer", "job_activity")
    
    
    g3 <- ggplot(result, aes(x = get(var), y = n)) + 
      geom_bar( aes(fill = "Frequency"), stat = "identity") + 
      geom_point(aes(x = get(var), y = r * result[, 3], 
                     color = paste0(binary))) + 
      geom_line( aes(x = get(var), y = r * result[, 3], group = 1, 
                     color = paste0(binary)), size = rel(1.4)) + 
      scale_fill_manual("", values = bar_color) +
      scale_colour_manual("", values = label) +
      scale_x_discrete(
        name = paste(var), 
        guide = guide_axis(n.dodge = ifelse(rotate_x_labels, 1, 2))
      ) +
      scale_y_continuous(
        name = "Frequency", labels = scales::comma, 
        sec.axis = sec_axis( ~ . * (1 / r), name = "Event Percentage",
                             labels = scales::percent) ) + 
      theme_bw() + 
      geom_hline(yintercept = 0, color = "grey", size = .5) + 
      theme(panel.border     = element_blank(),  
            panel.grid.minor = element_blank(), 
            panel.background = element_blank(),
            legend.position  = "top",
            legend.text      = element_text(size = rel(1.1)),
            axis.text.y      = element_text(size = rel(1.3)),
            axis.text.x      = element_text(
              size = rel(1.3), angle = ifelse(rotate_x_labels, -70, 0),
              hjust = ifelse(rotate_x_labels, 0, 0.5)),
            axis.title.x     = element_text(size = rel(1.3)),
            axis.title.y     = element_text(size = rel(1.3)),
            axis.line.y      = element_line(color = "grey", size = 0.5)
      )
    
    gindex <- paste0(sec, ".", gi) # Update the graph index
    
    cat(paste0("\n### Figure ", gindex, ". Percentage of ", row_name_short,
               " by ", var, ". {-} \n"))
    gi <- 1 + gi
    
    cat("\n")
    cat("\n")
    
    print(g3)
    
    cat("\n")
    cat("\n")
    
    # Save the plots to files
    if(save_plots){
      ppi <- 300
      graph_name <- paste0("ASF_", gindex, "_", var, "_", ini_time, ".png")
      graph_path  <- file.path(here::here(), "results", "graphs")
      png(filename = file.path(graph_path, graph_name), 
          width = 10 * ppi, height = 6 * ppi, res = ppi)
      cat("\n")
      cat("\n")
      
      print(g3)
      
      cat("\n")
      cat("\n")
      
      dev.off()
      
      cat("\n")
      cat("\n")
      
    } 
    
    
  }
}  


describeNumericAndBinaryResponse <- function(
    data, var, binary,
    ti = 1, gi = 1,
    ordinals         = NULL,
    filter_outliers  = FALSE,
    plot             = TRUE,
    bar_color        = "#006AA7",
    line_color1      = "#fff159",
    line_color2      = "#00bbfe", 
    row_name         = "records",
    save_plots       = FALSE,
    ini_time         = NULL,
    logname_eda      = NULL,
    n_intervals      = 10
){
  #' Calculate frequency and percentages for the different levels of variable 
  #' "var" in dataset "data" and display them in table and graph.
  #' 
  #' Arguments: 
  #'   data:             Data frame to use.
  #'   var:              Variable to analyze.
  #'   binary:         binary variable to analyze.
  #'   ti:               (default value: 1)
  #'   gi:               (default value: 1)  
  #'   ordinals:         (default value: NULL)
  #'   filter_outliers:  Indicator whether to filter outliers Q + RI 
  #'                     (default value: FALSE)
  #'   n_intervals:      Number of intervals to use
  #'                     (default value: 10)              
  #'   plot:             Indicates whether to create plots 
  #'                     (default value: TRUE)
  #'   bar_color:        (default value: "#0b0080" (Blue SC Seguros Generales))
  #'   line_color1:      (default value: "#00bbfe" (Light blue SC SG))
  #'   line_color2:      (default value: "#fff159" (Yellow SF))
  #'   row_name:         Name to use for the analyzed individuals
  #'                     (default value: "records")
  #'   save_plots:       Indicator whether to save the plots
  #'                     (default value: FALSE)
  #'   ini_time:         Identifier for date and time to save the names
  #'                     of the graphs to be saved.
  #'                     (default value: NULL)
  #'   logname_eda:      File where interpretations are to be saved
  #'                     (default value: NULL)               
  #'   
  #' Dependencies on packages: "ggplot2" (version 3.3.0 for using
  #' the function guide_axis() )
  #' Dependencies on function: "writeText" 
  
  require(ggplot2)
  require(knitr)
  require(dplyr)
  
  cat(paste0("\n### Variable: **", var, "**. {-} \n"))
  cat(paste0("\n"))
  cat(paste0("\n"))
  
  n_df <- length(data[, var])
  
  # Filter NA values, if any
  if( any(is.na(data[var])) ){
    
    n_na       <- length(data[var][is.na(data[var])])
    percent_na <- round(100 * n_na / n_df, 1)
    data       <- data[ ! is.na(data[var]), ]
    
    text_na <- 
      paste0("\nFor this analysis, ", n_na, " observations with 'NA' are not considered. They represent ", percent_na, "% of the total ", n_df,
             " records . \n")  
    
    writeText(text_na, logname = logname_eda)
    rm("text_na")
    
  }
  
  if( filter_outliers ){
    upper_limit <- 4 * quantile(data[, var], probs = c(0.75)) - 3 *
      quantile(data[, var], probs = c(0.25))    
    lower_limit <- 4 * quantile(data[, var], probs = c(0.25)) - 3 *
      quantile(data[, var], probs = c(0.75))
    
    n_out_upper  <- length(data[var][data[var] > upper_limit])
    n_out_lower  <- length(data[var][data[var] < lower_limit])
    percent_out_upper <- round(100 * n_out_upper / n_df, 1)
    percent_out_lower <- round(100 * n_out_lower / n_df, 1)
    
    if( n_out_upper > 0 ){
      # Summarize high extremes
      min_upper         <- min(   data[var][data[var] > upper_limit])
      max_upper         <- max(   data[var][data[var] > upper_limit])
      mean_upper        <- round(mean(data[var][data[var] > upper_limit]), 1)
      median_upper      <- round(median(data[var][data[var] > upper_limit]), 1)
      
      text_out_upper <- 
        paste0(
          "\n", n_out_upper, " observations (",
          percent_out_upper, "% of the total ", n_df, " records) ",
          "are not used as they are considered 'extremely high'. That is, the value of '", 
          var, "' is greater than ", round(upper_limit), " (determined by adding the 75th percentile and three times the interquartile range). ",
          "\nIn those ", n_out_upper, " observations, the variable varies ",
          "between ", round(min_upper), " and ", round(max_upper), " with a mean of ",
          round(mean_upper), " and a median of ", round(median_upper), ".\n")  
      
      writeText(text_out_upper, logname = logname_eda)
      rm("text_out_upper")
      
    }
    
    if( n_out_lower > 0 ){
      # Summarize low extremes
      min_lower         <- min(   data[var][data[var] < lower_limit])
      max_lower         <- max(   data[var][data[var] < lower_limit])
      mean_lower        <- mean(  data[var][data[var] < lower_limit])
      median_lower      <- median(data[var][data[var] < lower_limit])
      
      text_out_lower <- 
        paste0(
          "\nWhen analyzing the lowest values, ",
          n_out_lower, " observations are not used because they are considered 'extremely low'. That is, with values ", 
          "of '", var, "' lower than ", round(lower_limit), " (determined by subtracting the 25th percentile and three times ",
          "the interquartile range). ",
          "\nThey represent ", round(percent_out_lower), "% of the total ", 
          n_df, " records.\n",
          "\nIn those ", n_out_lower, " observations, the variable varies ",
          "between ", round(min_lower), " and ", round(max_lower), " with a mean of ",
          round(mean_lower)," and a median of ", round(median_lower), ".\n"
        ) 
      
      writeText(text_out_lower, logname = logname_eda)
      rm("text_out_lower")
      
    }
    
    # Filter the data
    data            <- data[ data[var] >= lower_limit &
                               data[var] <= upper_limit, ]
    
    
  }
  
  
  
  #--------------------
  interval_width      <- ( max(data[var]) - min(data[var])) / n_intervals
  
  if( interval_width == 0 ){
    writeText(
      paste0("\nIn the analyzed observations, the variable '", var, "' ",
             "always takes the same value equal to: '", max(data[var]), "'.\n"), 
      logname = logname_eda)
  } else{
    
    r1 <- ggplot(data = data, aes(x = get(var))) +
      geom_histogram(binwidth = interval_width, color="white", fill = bar_color) + 
      scale_x_continuous(name = paste0(var)) +        
      theme_bw() +                                            
      geom_hline(yintercept = 0, color = "grey", size = .5) + 
      theme(panel.border       = element_blank(),  
            panel.grid.minor   = element_blank(), 
            panel.background   = element_blank(),
            legend.position    = "top",
            legend.text        = element_text(size = rel(1.1)),
            axis.text.y        = element_text(size = rel(1.5)),
            axis.text.x        = element_text(size = rel(1.5)),
            axis.title.x       = element_text(size = rel(1.3)),
            axis.title.y       = element_text(size = rel(1.3)),
            axis.line.y = element_line(color = "grey", size = 0.5)
      )
    
    mean_bin <- function(df) {
      filter(data, get(var) > df$xmin & get(var) <= df$xmax) %>% 
        summarise(!!binary  := mean(get(binary))) %>% 
        mutate(!!binary  := ifelse(is.nan(get(binary)) , NA, 
                                   get(binary)))
    }
    
    bin_means <- group_by(ggplot_build(r1)$data[[1]], x) %>% 
      do(mean_bin(.)) %>%
      ungroup() 
    
    table_to_print <- data.frame(
      ggplot_build(r1)$data[[1]] %>% 
        dplyr::select(xmin, xmax, x, count ) %>% 
        rename( n = count ) %>% 
        merge(., bin_means, by = "x") %>% 
        dplyr::mutate(
          !!var             := paste0(xmin, " - ", xmax),
          percentage         = round( 100 * n / sum(n), 1),
          `n (percentage %)` = paste0(n, " (", sprintf("%3.1f%%", 
                                                       percentage), ")") 
        ) %>% 
        dplyr::select(- xmin, - xmax),   
      check.names = FALSE  )  
    
    
    
    # Update table index
    if( !exists("sec") ){ sec <- 1 }
    tindex <- paste0(sec, ".", ti)
    
    # Sort the table to find the highest binary percentages
    t_ord2 <- table_to_print %>% arrange(- get(binary)) %>% 
      mutate(!!binary := as.factor(sprintf("%3.1f%%", 100 * get(binary))))
    
    text <- 
      paste0("\n**The highest percentage of '", binary, "' occurs in the interval ",
             "of '", var,  "': '*", t_ord2[1, var], "*', with: ", 
             t_ord2[1, binary], "**. The next highest percentage is in ",
             "the interval: '*", t_ord2[2, var], "*', with: ", t_ord2[2, binary], 
             " (Table ", tindex,"). \n")  
    
    writeText(text, logname = logname_eda)
    
    
    row_name_short <- substr(row_name, 5, nchar(row_name))
    
    table_title <- paste0(
      "\n### Table ", tindex,". Count (and percentage) of ", row_name_short, 
      " and proportion of events for '", binary,
      "according to different intervals of '",  var,  "'. {-} ")
    
    cat(table_title)
    ti <- 1 + ti
    
    print(kable(table_to_print[, c(paste0(var), "n (percentage %)", 
                                   paste0(binary))],
                row.names = FALSE, align = c('l', 'r','r'),
                digits = 3))
    
    cat("\n")
    
    if(plot){ 
      result <- table_to_print 
      
      # Relationship between different quantities in the plots
      r <- max(result$n) /  max(result[, paste0(binary )], na.rm = TRUE)
      
      label <- structure(c(bar_color, line_color2), 
                         .Names = c("Frequency", binary))
      
      
      g3 <- r1 + 
        geom_point(
          data = result, aes(x = x, y = r * result[, binary], color = binary)
        ) + 
        geom_line( 
          data = result, aes(x = x, y = r * result[, binary], group = 1, 
                             color = binary), size = rel(1.4)
        )  +  
        scale_fill_manual(  "", values = bar_color) +
        scale_colour_manual("", values = label) +
        scale_y_continuous(
          name = "Frequency", labels = scales::comma, 
          sec.axis = sec_axis( ~ . * (1 / r), name = "Event Percentage",
                               labels = scales::percent) )
      
      gindex <- paste0(sec, ".", gi) # Update the graph index
      
      cat(paste0("\n### Figure ", gindex, ". Percentage of '", binary,
                 "' according to '", var, "' intervals. {-} \n"))
      gi <- 1 + gi
      
      cat("\n")
      cat("\n")
      
      print(g3)
      
      cat("\n")
      cat("\n")
      
      
      
      # Save the plots to files
      if(save_plots){
        ppi <- 300
        graph_name <- paste0("ASF_", gindex, "_", var, "_", ini_time, ".png")
        graph_path  <- file.path(here::here(), "results", "graphs")
        png(filename = file.path(graph_path, graph_name), 
            width = 10 * ppi, height = 6 * ppi, res = ppi)
        print(g3)
        cat("\n")
        cat("\n")
        dev.off()
        cat("\n")
        cat("\n")
      } 
      
    }
  }  
  
}  



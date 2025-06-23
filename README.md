# Segmentation in Machine Learning Models


Introduction
--------
This repository seeks to compare the performance of machine learning models with and without a previous segmentation.


📄 Dataset Description
--------
This project uses a dataset consisting of a random sample of 23,857 tax identification numbers (CUITs) of individuals who had at least one debt in the Argentine financial system in June 2019, and were classified in credit situation 1 or 2 (i.e., no overdue payments exceeding 90 days), according to the Central Bank of Argentina (BCRA).

For each CUIT in the sample, debts across all financial entities were recorded and summarized for June 2019 and the six preceding months. Additionally, debt information from July 2019 to June 2020 was collected to analyze credit behavior over time.

The binary response variable indicates whether the CUIT experienced a severe credit situation (equal to or greater than 3) at any point between July 2019 and June 2020. The dataset includes 28 anonymized variables with masked names.

🔍 Executive summary
--------
All modeling approaches showed improved weighted AUC when using segmentation and fitting separate models per group.

The improvement was most noticeable with logistic regression, likely due to its more limited capacity to model complex patterns globally.

A smaller test set (i.e., larger training set) consistently led to higher AUCs across all methods.

For test_size = 5%, segments almost always showed both higher and lower AUCs than the non-segmented model, highlighting substantial heterogeneity across subgroups.


Folder Structure
--------
The project is organized into the following folders:

    segmantation_in_machine_learning_models
    |
    |- data/    
    |- results/
    |- scratch/
    |- src/   
    |
    |- README.md                   # folder description
    
    
References
--------
- 

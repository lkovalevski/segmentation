# Cooperative Learinig In Argentinian Risk Scoring Dataset


Introduction
--------
This repository seeks to evaluate the method: Cooperative Learning [Cooperative Learning Resources] for multiview data on a credit risk scoring data set, comparing it with traditional supervised learning methods.

Cooperative learning combines the usual squared error loss of predictions with an ''agreement'' penalty to encourage the predictions from different data views to agree. The method can be especially powerful when the different data views share some underlying relationship in their signals that can be exploited to boost the signals.

Unlike traditional ensemble methods, where individual models work independently and their outputs are combined later, cooperative learning enables models to learn from each other iteratively. This collaborative interaction allows the models to correct each other's weaknesses, resulting in more accurate and generalized predictions.




![Figure01](results/figures/early_late.png)
*https://tibshirani.su.domains/multiview/files/image/early_late.png*


Folder Structure
--------
The project is organized into the following folders:

    coop_learinig_in_risk_scoring
    |
    |- data/    
    |- results/
    |- scratch/
    |- src/   
    |
    |- README.md                   # folder description
    
    
    
    
[Cooperative Learning Resources]: https://tibshirani.su.domains/multiview/CoopLearning.html





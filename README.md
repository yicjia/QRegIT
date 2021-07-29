# QRegIT
 *QRegIT* is an R package for quantile (Q) regression (Reg) on inactivity (I) time (T). The inactivity time can be interpreted as time lost due to an event of interest, reversed lifetime, or time beyond an adverse event such as transition to an addictive drug. We propose a quantile regression model to associate the inactivity time with potential predictors, adjusting for confounding factors. This function can also handle competing risks data.
 
 Please refer to our paper for more details: https://onlinelibrary.wiley.com/doi/10.1002/sim.8871
 
 
  
 ## Installation

Install QRegIT from Github
```
install.packages("devtools")
library(devtools)
install_github("yicjia/QRegIT")
```

## Usage
```
QRegIT(time, event, cov, t0, tau, type = 1, nPerturb = 400)
```

## Arguments
* *time* :	the follow up time
* *event* :	the status indicator, normally 0 = censored
* *cov* :	the covariate(s) used in the regression
* *t0* :	a pre-specified time point used to define inactivity time. t0 can be chosen from the observation period whose maximum would be the administrative censoring
* *tau* : the desired quantile; this is a number strictly between 0 and 1
* *type* :	the event of primary interest when competing risks are present. When there are no competing events, the default is type = 1.
* *nPerturb* :	the number of perturbations; default = 400

## Values
QRegIT returns a data frame containing the estimated coefficients and 95% CI.

## Example:
```
# First load QRegIT R package
library(QRegIT)

# Load the example data testdata
data("testdata")

# Test run of QRegIT
cov <- testdata[,c("x1","x2","x3")]
testRun <- QRegIT(testdata$time, testdata$event, cov, t0 = 15, tau = 0.5, type = 1, nPerturb = 1000)
```
 
 ## Reference
 ### If you use QRegIT in your research, please consider citing: 
 Jia, Y., & Jeong, J. H. (2021). Cause‐specific quantile regression on inactivity time. Statistics in Medicine, 40(7), 1811-1824.
```
@article{jia2021cause,
  title={Cause-specific quantile regression on inactivity time},
  author={Jia, Yichen and Jeong, Jong-Hyeon},
  journal={Statistics in Medicine},
  volume={40},
  number={7},
  pages={1811--1824},
  year={2021},
  publisher={Wiley Online Library}
}
```

# QRLL
 *QRLL* is an R package for quantile regression on inactivity time (lost lifespan). The inactivity time, or lost lifespan, is the time lost due to an event occurring prior to a specified time point, t0. We propose a quantile regression model to associate the inactivity time with potential predictors. This function can also handle competing risks data.
 
 ## Installation

Install QRLL from Github
```
install.packages("devtools")
library(devtools)
install_github("yicjia/QRLL")
```

## Usage
```
QRLL(time, event, cov, t0, tau, type = 1, nPerturb = 400)
```

## Arguments
* *time* :	the follow up time
* *event* :	the status indicator, normally 0 = censored
* *cov* :	the covariate(s) used in the regression
* *t0* :	a pre-specified time point used to define inactivity time or lost lifespan. t0 can be chosen from the observation period whose maximum would be the administrative censoring.
* *tau* : the quantile desired, this is a number strictly between 0 and 1,
* *type* :	the event of primary interst when competing risks present. If no competing risks, then leave it blank.
* *nPerturb* :	the number of perturbations. Default = 400

## Values
QRLL returns a data frame containing the estimated coefficients and 95% CI.

## Example:
```
# First load QRLL R package
library(QRLL)

# Load the example data testdata
data("testdata")

# Test run of QRLL
cov <- testdata[,c("x1","x2","x3")]
testRun <- QRLL(testdata$time, testdata$event, cov, t0 = 15, tau = 0.5, type = 1, nPerturb = 1000)
```

#include <RcppArmadillo.h>
#include <Rcpp.h>
#include <math.h>
#include <vector>
#include <string>
#include <random>
#include <algorithm>

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins(cpp11)]]


// Estimating quantile inactivity time (lost lifespan) for time-to-event data
//
// QRLL function
// @name QRLL
// @aliases QRLL
// @param time the follow up time
// @param event the status indicator, normally 0 = censored
// @param cov the covariate(s) used in the regression
// @param t0 a pre-specified time point used to define inactivity time. t0 can be chosen from the observation period whose maximum would be the administrative censoring.
// @param tau the quantile desired, this is a number strictly between 0 and 1,
// @param type the event type of primary interst when competing risks present. If no competing risks, then leave it blank.
// @param nPerturb the number of perturbations. Default = 400
// @return QRLL returns a data frame contianing estimated coefficients and 95% CI based on perturbation resampling.
// @author Yichen Jia, Jong-Hyeon Jeong.


using namespace std;

// [[Rcpp::depends(RcppArmadillo)]]

// [[Rcpp::export]]
arma::mat SC_func(arma::vec& Time, arma::vec& censor, arma::vec& wgt) {
  arma::vec deathtime = arma::unique(arma::sort(Time.elem(arma::find(censor == 1))));
  int length = deathtime.n_elem;
  
  arma::vec nrisk = arma::zeros<arma::vec>(length);
  arma::vec ndeath = arma::zeros<arma::vec>(length);
  for (int i=0; i<length; i++) {
    nrisk(i) = arma::sum(wgt.elem(arma::find(Time >= deathtime(i))));
    ndeath(i) = arma::sum(wgt.elem(arma::find(Time == deathtime(i) && censor == 1)));
  }
  arma::vec prodobj = 1 - ndeath/nrisk;
  
  arma::vec survp = arma::zeros<arma::vec>(length);
  for (int i=0; i<length; i++) {
    survp(i) = prod(prodobj.subvec(0,i));
  }
  
  arma::mat out = arma::zeros<arma::mat>(length,4);
  out.col(0) = deathtime;
  out.col(1) = ndeath;
  out.col(2) = nrisk;
  out.col(3) = survp;
  
  return out;
}



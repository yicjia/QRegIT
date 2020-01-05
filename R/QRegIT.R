## usethis namespace: start
#' @useDynLib QRegIT, .registration = TRUE
## usethis namespace: end
NULL

## usethis namespace: start
#' @importFrom Rcpp sourceCpp
## usethis namespace: end
NULL

# fit the quantile regression
#' @import quantreg
#' @import stats
fit.fun=function(time, event, cov, SC, wt=1, type, t0, tau){
  n = length(time)
  XX = cbind(rep(1, n), cov)
  G.T=pmax(SC(time),0.005)
  weight.T=as.numeric(time<=t0)*as.numeric(event==type)/G.T*wt
  fit.Y=log(pmax(t0-time,0.0000000001))
  fit.rq=rq.wfit(x = XX, y = fit.Y, weights = weight.T, tau = tau)
  fit.coef=fit.rq$coef
  return(fit.coef)
}

#' QRegIT function
#'
#' QRegIT is an R package for quantile (Q) regression (Reg) on inactivity (I) time (T). The inactivity time can be interpreted as time lost due to an event of interest, reversed lifetime, or time beyond an adverse event such as transition to an addictive drug. We propose a quantile regression model to associate the inactivity time with potential predictors, adjusting for confounding factors.
#' @param time the follow up time
#' @param event the status indicator, normally 0 = censored
#' @param cov the covariate(s) used in the regression
#' @param t0 a pre-specified time point used to define inactivity time. t0 can be chosen from the observation period whose maximum would be the administrative censoring.
#' @param tau the desired quantile; this is a number strictly between 0 and 1.
#' @param type the event of primary interest when competing risks are present. When there are no competing events, the default is type = 1.
#' @param nPerturb the number of perturbations; default = 400
#' @return QRegIT returns a data frame contianing estimated coefficients and 95 percent confidence interval.
#' @author Yichen Jia <yij22@pitt.edu>, Jong-Hyeon Jeong <jjeong@pitt.edu>.
#' @references Yichen Jia, Jong-Hyeon Jeong. Cause-Specific Quantile Regression on Inactivity Time. Submitted 2019.
#' @examples
#' # Load the example data testdata
#' data("testdata")
#' # Test run of QRegIT:
#' cov = testdata[,c("x1","x2","x3")]
#' testRun = QRegIT(testdata$time, testdata$event, cov, t0 = 15, tau = 0.5, type = 1, nPerturb=1000)
#' # End
#' @import stats
#' @export
QRegIT = function(time, event, cov, t0, tau, type=1, nPerturb=400) {
  temp = deparse(substitute(cov))
  if (temp!="cov") {
    out_name = temp
    cov = as.data.frame(cov)
  } else {
    cov = as.data.frame(cov)
    out_name = colnames(cov)
  }

  n = length(time)
  cov = as.matrix(cov)

  SC0=SC_func(time,as.numeric(event==0), wgt = rep(1,n))
  SC0 = data.frame(SC0)
  colnames(SC0) = c("deathtime", "ndeath", "nrisk", "survp")
  SC=stepfun(SC0$deathtime,c(1,SC0$survp),right=TRUE)
  bhat=fit.fun(time, event, cov, SC=SC, wt=1, type, t0, tau)

  bhat.purturb = NULL
  for (b in 1:nPerturb) {
    p.wt=rexp(n)
    SC0.wt=SC_func(time,as.numeric(event==0),p.wt)
    SC0.wt = data.frame(SC0.wt)
    colnames(SC0.wt) = c("deathtime", "ndeath", "nrisk", "survp")
    SC.p=stepfun(SC0.wt$deathtime,c(1,SC0.wt$survp),right=TRUE)
    fit.wt=fit.fun(time,event, cov, SC=SC.p, wt=p.wt, type, t0, tau)
    bhat.purturb = rbind(bhat.purturb, fit.wt)
  }
  max.check = apply(abs(bhat.purturb),1,max)
  bhat.purturb[max.check>=10,] = NA
  sd.est = apply(bhat.purturb,2,sd,na.rm=T)

  c = ncol(cov)
  out = NULL
  for(i in 1:(c+1)) {
    est = bhat[i]
    CIlower = est - 1.96*sd.est[i]
    CIupper = est + 1.96*sd.est[i]
    temp = c(est, CIlower, CIupper)
    out = rbind.data.frame(out, temp)

  }
  colnames(out) = c("Estimate","95%CI lower", "95%CI upper")
  rownames(out) = c("(Intercept)", out_name)


  return(out)
}





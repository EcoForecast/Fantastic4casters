
ParseFixed <- function(fixed,cov.data,update=NULL,ancillary.dims=NULL){
  
  if(FALSE){
    ## DEV TESTING FOR X, polynomial X, and X interactions
    fixed <- "X + X^3 + X*bob + bob + dia + X*Tmin[t]" ## faux model, just for testing jags code
  }
  
  ## set up string variables (OK for many to start NULL)
  data = update$data
  out.variables = update$out.variables
  Pformula = update$Pformula
  Xpriors = update$Xpriors
  Pnames = update$Pnames
  MDprior = update$MDprior
  MDformula = update$MDformula
  
  ## parse if working with a single time series or additional dimensions
  if(is.null(ancillary.dims)){
    AD=""
  } else {
    AD=ancillary.dims
  }
  
  ## Design matrix
  if (is.null(fixed)) {
    Xf <- NULL
  } else {
    
    ## check for covariate data (note: will falsely fail if only effect is X)
    if (is.null(cov.data)) {
      print("formula provided but covariate data is absent:", fixed)
    } else {
      cov.data <- as.data.frame(cov.data)
    }
    
    ## check if there's a tilda in the formula
    if (length(grep("~", fixed)) == 0) {
      fixed <- paste("~", fixed)
    }
    
    ## First deal with endogenous terms (X and X*cov interactions)
    fixedX <- gsub("[[:space:]]", "", sub("~","",fixed, fixed=TRUE))
    lm.terms <- unlist(strsplit(fixedX,split = "-",fixed=TRUE))  ## split on -
    if(length(lm.terms) > 0 & lm.terms[1] == ""){ ## was negative
      lm.terms = lm.terms[-1]
      lm.terms[1] = paste0("-",lm.terms[1])
    }
    if(length(lm.terms)>1){lm.terms[2] = paste0("-",lm.terms[2])} ## restore later minus
    lm.terms <- unlist(strsplit(lm.terms,split = "+",fixed=TRUE))  ## split on + and remove whitespace
    if(length(lm.terms)>0){
      X.terms <- strsplit(lm.terms,split = c("^"),fixed = TRUE)
      X.terms <- sapply(X.terms,function(str){unlist(strsplit(str,,split="*",fixed=TRUE))})
      X.terms <- which(sapply(X.terms,function(x){any(toupper(x) == "X")}))
    }
    if(length(X.terms) > 0){
      ## rebuild fixed without X.terms
      fixed <- paste("~",paste(lm.terms[-X.terms],collapse = " + "))  
      
      ## isolate terms with X
      X.terms <- lm.terms[X.terms]
      for(i in seq_along(X.terms)){
        
        myBeta <- NULL
        Xformula <- NULL
        if(length(grep("*",X.terms[i],fixed = TRUE)) == 1){  ## INTERACTION
          
          myIndex <- "[t-1]"             ### changed this from i to t, may break things 7/10/19 ***
          covX <- strsplit(X.terms[i],"*",fixed=TRUE)[[1]] 
          covX <- covX[-which(toupper(covX)=="X")] ## remove X from terms
          
          ##is covariate fixed or time varying?
          tvar <-  length(grep("[t]",covX,fixed=TRUE)) > 0           
          if(tvar){
            covX <- sub("[t]","",covX,fixed = TRUE)
            if(!(covX %in% names(data))){
              ## add cov variables to data object
              data[[covX]] <- time_data[[covX]]
            }
            check.dup.data(data,"covX")
            
            myIndex <- "[i,t]"
          } else {
            ## variable is fixed
            if(covX %in% colnames(cov.data)){ ## covariate present
              if(!(covX %in% names(data))){
                ## add cov variables to data object
                data[[covX]] <- cov.data[,covX]
              }
              check.dup.data(data,"covX2")
              
            } else {
              ## covariate absent
              warning("covariate absent from covariate data:", covX)
            }
            
          } ## end fixed or time varying
          
          myBeta <- paste0("betaX_",covX)
          Pnames = c(Pnames,covX)
          Xformula <- paste0(myBeta,"*x[",AD,"t-1]*",covX,myIndex)  ## was x[i,t-1]
          
        } else if(length(grep("^",X.terms[i],fixed=TRUE))==1){  ## POLYNOMIAL
          powX <- strsplit(X.terms[i],"^",fixed=TRUE)[[1]] 
          powX <- powX[-which(toupper(powX)=="X")] ## remove X from terms
          myBeta <- paste0("betaX",powX)
          Xformula <- paste0(myBeta,"*x[",AD,"t-1]^",powX)
          
        } else {  ## JUST X
          myBeta <- "betaX"
          Xformula <- paste0(myBeta,"*x[",AD,"t-1]")
        }
        
        Pformula <- paste(Pformula,"+",Xformula)
        
        ## add priors
        Xpriors <- paste(Xpriors,"     ",myBeta,"~dnorm(0,0.001)\n")
        
        ## add to out.variables
        out.variables <- c(out.variables, myBeta)
        
      }  ## END LOOP OVER X TERMS
      
    }  ## end processing of X terms
    Pnames = unique(Pnames)
    
    ############ build DESIGN MATRIX from formula #########
    fixedX <- sub("~","",fixed, fixed=TRUE)
    lm.terms <- gsub("[[:space:]]", "", strsplit(fixedX,split = "+",fixed=TRUE)[[1]])  ## split on
    if(lm.terms[1] != ""){
      Xf = model.matrix(formula(fixed),
                        data = model.frame(formula(fixed), cov.data,na.action = na.pass),
                        na.action = na.pass)
      Xf.cols <- colnames(Xf)
      Xf.cols <- sub(":","_",Xf.cols) ## for interaction terms, switch separator
      colnames(Xf) <- Xf.cols
      # Xf.cols <- Xf.cols[Xf.cols != "(Intercept)"]
      # Xf      <- as.matrix(Xf[, Xf.cols])
      # colnames(Xf) <- Xf.cols
      ##Center the covariate data
      #    Xf.center <- apply(Xf, 2, mean, na.rm = TRUE)
      #    Xf      <- t(t(Xf) - Xf.center)
      
      ## drop -1 term, isn't part of design so shouldn't get a beta
      if(ncol(Xf) == 0) Xf <- NULL
      
    } else {Xf <- NULL} ## end fixed effects parsing
    
    
    ## build formula in JAGS syntax
    if (!is.null(Xf)) {
      Xf.names <- gsub(" ", "_", colnames(Xf))  ## JAGS doesn't like spaces in variable names
      Xf.names <- gsub("(", "", Xf.names,fixed=TRUE)  ## JAGS doesn't like parentheses in variable names
      Xf.names <- gsub(")", "", Xf.names,fixed=TRUE)
      
      ## remove items from design matrix that are already in model
      real.names <- Xf.names[Xf.names %in% Pnames]
      sel <- which(Xf.names %in% real.names)
      if(length(sel)>0){
        Xf <- as.data.frame(Xf)
        Xf <- Xf[,-sel,drop=FALSE]
        Xf.names <- Xf.names[-sel]
      }
      
      ## append to process model formula: Xf
      if(ncol(Xf)>0){
        Pformula <- paste(Pformula,
                          paste0("+ beta", Xf.names, "*Xf[t,", seq_along(Xf.names), "]", collapse = " "))  # was Xf[rep[i]
        Xpriors <- paste(Xpriors,paste0("     beta", Xf.names, "~dnorm(0,0.001)", collapse = "\n"))
        MDprior <- paste(MDprior,
                         "for(j in 1:",ncol(Xf),"){\n",
                         "   muXf[j] ~ dnorm(0,0.001)\n",
                         "   tauXf[j] ~ dgamma(0.01,0.01)\n",
                         "}\n")
        MDformula <- paste(MDformula,
                           paste0("Xf[t,",seq_along(Xf.names),
                                  "] ~ dnorm(muXf[",seq_along(Xf.names),
                                  "],tauXf[",seq_along(Xf.names),"])",collapse="\n")
        )
        out.variables <- c(out.variables, paste0("beta", Xf.names))
      }
      ## append using real names
      if(length(real.names) > 0){
        Pformula <- paste(Pformula,
                          paste0("+ beta", real.names, "*",real.names,"[t]", collapse = " "))
        Xpriors <- paste(Xpriors,paste0("     beta", real.names , " ~ dnorm(0,0.001)", collapse = "\n"))
        out.variables <- c(out.variables, paste0("beta", real.names))
      }
      
      ## create 'rep' variable if not defined
      #     if(is.null(data$rep)){
      #        data$rep <- seq_len(nrow(Xf))
      #      }
      
      ## update variables for JAGS to track
      data[["Xf"]] <- Xf
    }
    ## missing data model for Pnames (do only once across both interactions and Xf)
    missCol <- which(Pnames != "Intercept")
    if(length(missCol)>0){
      Pmiss <- Pnames[missCol]
      MDprior <- paste(
        paste0("mu",Pmiss,"~dnorm(0,0.001)",collapse="\n"),"\n",
        paste0(" tau",Pmiss,"~dgamma(0.01,0.01)",collapse="\n")
      )
      MDformula <- paste0(Pmiss,"[t] ~ dnorm(mu",Pmiss,",tau",Pmiss,")",collapse="\n")
    }
    
    check.dup.data(data,"Xf")
    
  } ## END FIXED IS NOT NULL
  
  return(list(Pformula=Pformula,out.variables=out.variables,Xpriors=Xpriors,
              MDprior=MDprior, MDformula=MDformula,data=data))
}

check.dup.data <- function(data,loc){
  if(any(duplicated(names(data)))){warning("duplicated variable at ",loc," ",names(data))}
}

if(FALSE){
  ## DUMPING GROUND
  TreeDataFusionMV <- sub(pattern = "## ENDOGENOUS BETAS", Xpriors, TreeDataFusionMV)
  TreeDataFusionMV <- sub(pattern = "## FIXED EFFECTS BETAS", Xf.priors, TreeDataFusionMV)
  
}

##' @name fit_dlm
##' @title fit_dlm
##' @author Mike Dietze
##' @export
##' @param model list containing the following elements
##' \itemize{
##'  \item{obs}{column name of the observed data. REQUIRED}
##'  \item{fixed}{formula for fixed effects. Response variable is optional but should be 'x' if included}
##'  \item{random}{not implemented yet; will be formula for random effects}
##'  \item{n.iter}{number of mcmc iterations}
##' }
##' @param data  data frame containing observations and covariates
##' @param dic   whether or not to calculate DIC
##' @description Fits a Bayesian state-space dynamic linear model using JAGS
fit_dlm <- function(model=NULL,data,dic=TRUE){
  
  obs    = model$obs
  fixed  = model$fixed
  random = model$random
  n.iter = ifelse(is.null(model$n.iter),5000,model$n.iter)
  n.thin = ifelse(is.null(model$n.thin),10,model$n.thin)
  
  data = as.data.frame(data)
  
  out.variables = c("x","tau_obs","tau_add")
  Pformula = NULL
  
  ## observation design matrix
  if(is.null(obs)){
    print("Observations not included in model. Please add the variable 'obs' to the model list")
  } else {
    if(length(grep("~",obs)) == 0){ ## no formula, assuming obs is just a variable
      if(obs %in% names(data)){
        OBS = data[,obs]
      } else {
        print(paste("Could not find",obs,"in the provided data frame"))
        return(NULL)
      }
    } else {  ## obs is a formula
      print("obs formulas not implemented yet")
      return(NULL)
    }
  }
  
  #### prep data
  mydat<-list(OBS=OBS,n=length(OBS),x_ic = 0,tau_ic = 0.00001,a_obs=0.1,r_obs=0.1,a_add=0.1,r_add=0.1)
  
  
  ## process design matrix
  if(is.null(fixed) | fixed == ""){
    fixed = NULL
  } else {
    if(is.null(data)) print("formula provided but covariate data is absent:",fixed)
    design <- ParseFixed(fixed,cov.data=data,
                         update=list(out.variables=out.variables,
                                     data = mydat))
    #    Z = as.matrix(Z[,-which(colnames(Z)=="(Intercept)")])
    if(sum(is.na(design$data))>0){
      print("WARNING: missing covariate data")
      print(apply(is.na(design$data),2,sum))
    }
  }
  ## alternatively might be able to get fixed and random effects simultaneously using
  ## lme4::lFormula(formula("x ~ FIXED + (1|FACTOR)"),na.action=na.pass)
  ## e.g. foo = lme4::lFormula(formula("x ~ PAR + (1+PAR|DOY)"),na.action = na.pass)
  
  
  
  #### Define JAGS model
  my.model = "  
  model{
  
  #### Priors
  x[1] ~ dnorm(x_ic,tau_ic)
  tau_obs ~ dgamma(a_obs,r_obs)
  tau_add ~ dgamma(a_add,r_add)

  #### Random Effects
  #RANDOM  tau_alpha~dgamma(0.1,0.1)
  #RANDOM  for(i in 1:nrep){                  
  #RANDOM   alpha[i]~dnorm(0,tau_alpha)
  #RANDOM  }

  #### Fixed Effects
  ##BETAs
  ##MISSING_MU
  
  #### Data Model
  for(t in 1:n){
    OBS[t] ~ dnorm(x[t],tau_obs)
    ##MISSING
  }
  
  #### Process Model
  for(t in 2:n){
    mu[t] <- x[t-1] ##PROCESS
    x[t]~dnorm(mu[t],tau_add)
  }

  }"
  
  
  #### prep model
  if(!is.null(fixed)){
    
    ## Insert regression priors
    my.model = sub(pattern="##BETAs",design$Xpriors,my.model)  
    out.variables = design$out.variables
    mydat = design$data
    Pformula = design$Pformula
    Pnames = unique(design$Pnames)
    
    ## missing data model
    if(!is.null(design$MDprior)){
      my.model <- sub(pattern="##MISSING_MU",design$MDprior,my.model)
      my.model <- sub(pattern="##MISSING",design$MDformula,my.model)
    }
  }
  
  ## RANDOM EFFECTS
  if(!is.null(random)){
    my.model = gsub(pattern="#RANDOM"," ",my.model)
    out.variables = c(out.variables,"tau_alpha","alpha")  
    Pformula = " + alpha[rep[i]]"
    ## *****
    ## need to do work here to specify indicator variables for random effects explictly
    ## *****
  }
  
  if(!is.null(Pformula)) my.model = sub(pattern="##PROCESS",Pformula,my.model)
  
  ## Define initial conditions
  
  
  print(my.model)
  ## initialize model
  mc3 <- rjags::jags.model(file=textConnection(my.model),data=mydat,
                           n.chains=3)
  
  mc3.out <- rjags::coda.samples(model=mc3, variable.names=out.variables, n.iter=n.iter,thin=n.thin)
  
  ## split output
  out = list(params=NULL,predict=NULL,model=my.model,data=mydat)
  mfit = as.matrix(mc3.out,chains=TRUE)
  pred.cols = union(grep("x[",colnames(mfit),fixed=TRUE),grep("mu[",colnames(mfit),fixed=TRUE))
  chain.col = which(colnames(mfit)=="CHAIN")
  out$predict = mat2mcmc.list(mfit[,c(chain.col,pred.cols)])
  out$params   = mat2mcmc.list(mfit[,-pred.cols])
  if(dic) out$DIC <- dic.samples(mc3, 2000)
  return(out)
  
}  ## end fit_dlm



BuildZ <- function(fixed, data) {
  if (toupper(fixed) == "RW") {
    return(NULL)
  } else {
    fixed = ifelse(length(grep("~", fixed)) == 0, paste("~", fixed), fixed)
    fixed = sub("x*~", "~", x = fixed)
    options(na.action = na.pass)
    #  Z = with(data,model.matrix(formula(fixed),na.action=na.pass))
    Z = model.matrix(formula(fixed),
                     data = model.frame(formula(fixed), data),
                     na.action = na.pass)
    return(Z)
  }
}
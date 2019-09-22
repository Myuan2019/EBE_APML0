EBEL0<-function(myData,myData_x)
{
  myData <- groupedData( DV ~ Time | ID,
                         data = myData,
                         labels = list( x = "Time", y = "DAD"))
  cov.mx1<-as.matrix(myData_x)
  N<-nrow(cov.mx1)
  
  ######EBE##########
  
  
  ## fit nlme model
  mftime1 <- proc.time() ##current time###
  
  fit1 <- try(lme(DV ~ Time, data = myData, random = pdDiag(~Time), method="ML"), silent=TRUE)
  
  
  if(inherits(fit1,"try-error")) {
    
    output = rep(NA, 6) 
    
  } else {
    
    ####### 2. extract EBEs 
    ind.parm <- ranef(fit1, augFrame = T,  data=myData)
    ind.parm = ind.parm[order(ind.parm$ID2), ] 
    
    sh.in <- 100*(1-var(ind.parm[,1])/as.numeric(VarCorr(fit1)[1,1]))#(sd.ETA^2)
    sh.sl <- 100*(1-var(ind.parm$Time)/as.numeric(VarCorr(fit1)[2,1]))#(sd.ETA^2)
    
    ## set up for apml0
    
    x = cov.mx1
    y = ind.parm$Time
    
    
    
    
    
    ######################  START  ###########################
    
    
    ## Split data for cross-validatoin
    foldid=sample(rep(seq(10), length=N))
    
    mftime2 <- proc.time()  
    ebtime<-mftime2-mftime1  ###EBE time###
    
    ## glmnet - Enet 
    m1ftime1 <- proc.time()
    fitS2=list(); alphaS=c(1,5,10)/10; out3=NULL
    for (ia in 1:length(alphaS)) {
      fitS2[[ia]]=cv.glmnet(x,y, family="gaussian", alpha=alphaS[ia],foldid=foldid)
      out3=c(out3, min(fitS2[[ia]]$cvm))
    }
    fiti=fitS2[[which.min(out3)]]
    m1ftime <- proc.time() - m1ftime1+ebtime
    beta1i=fiti$glmnet.fit$beta[,which.min(fiti$cvm)]
    
    ## glmnet - Lasso 
    m2ftime1 <- proc.time()
    fiti=cv.glmnet(x,y, family="gaussian", alpha=1,foldid=foldid)
    m2ftime <- proc.time() - m2ftime1+ebtime
    beta1j=fiti$glmnet.fit$beta[,which.min(fiti$cvm)]
    
    
    ## APML0 - Enet
    m3ftime1 <- proc.time()
    fitS2=list(); alphaS=c(1,5,10)/10; out3=NULL; out4=NULL
    for (ia in 1:length(alphaS)) {
      fitS2[[ia]]=APML0(x, y, alpha=alphaS[ia],family="gaussian",foldid=foldid)
      out3=c(out3, min(fitS2[[ia]]$fit$cvm))
      out4=rbind(out4, fitS2[[ia]]$fit0$cvm)
    }
    fiti=fitS2[[which.min(out3)]]
    beta3i=fiti$Beta
    
    fiti=fitS2[[which.min(out4)]]
    beta3j=fiti$Beta0
    
    m3ftime <- proc.time() - m3ftime1+ebtime
    
    ## APML0 - Lasso
    m4ftime1 <- proc.time()
    fiti=APML0(x, y, alpha=1,family="gaussian",foldid=foldid)
    m4ftime <- proc.time() - m4ftime1+ebtime
    beta2i=fiti$Beta
    beta2j=fiti$Beta0
    
    ## APML0 - Enet + BIC
    m5ftime1 <- proc.time()
    
    xi=x; beta3jb=numeric(ncol(x))
    if (any(beta3j!=0)) {
      indexi0=which(beta3j!=0)
      xi=x[,indexi0,drop=F]
      
      fit2=APML0B(xi, y, foldid=foldid)
      
      beta3jb=numeric(ncol(x))
      beta3jb[indexi0]=fit2$Beta0
    }
    
    m5ftime <- proc.time() - m5ftime1+ m3ftime
    
    ## APML0 - Lasso + BIC
    m6ftime1 <- proc.time()
    
    xi=x; beta2jb=numeric(ncol(x))
    if (any(beta2j!=0)) {
      indexi0=which(beta2j!=0)
      xi=x[,indexi0,drop=F]
      
      fit2=APML0B(xi, y, foldid=foldid)
      
      beta2jb=numeric(ncol(x))
      beta2jb[indexi0]=fit2$Beta0
    }
    
    m6ftime <- proc.time() - m6ftime1+ m4ftime
    
    snpa1=which(beta1i!=0)
    snpa2=which(beta1j!=0)
    snpc1=which(beta3i!=0)
    snpc2=which(beta3j!=0)
    snpc3=which(beta3jb!=0)
    snpb1=which(beta2i!=0)
    snpb2=which(beta2j!=0)
    snpb3=which(beta2jb!=0)
    
    GLMal=c(m1ftime[3],snpa1,beta1i[snpa1])
    GLMa2=c(m2ftime[3],snpa2,beta1j[snpa2])
    APML0cl=c(m3ftime[3],snpc1,beta2i[snpc1])
    APML0c2=c(m3ftime[3],snpc2,beta2i[snpc2])
    APML0c3=c(m5ftime[3],snpc3,beta2i[snpc3])
    APML0bl=c(m4ftime[3],snpb1,beta2i[snpb1])
    APML0b2=c(m4ftime[3],snpb2,beta2j[snpb2])
    APML0b3=c(m6ftime[3],snpb3,beta2jb[snpb3])
    
   output = list(enet=GLMal,lasso=GLMa2,l0enet=APML0c2,l0enetbic=APML0c3,l0lasso=APML0b2, l0lassobic=APML0b3)
  } 
  return(output)
}
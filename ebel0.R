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

    
    ## Lasso 
    m2ftime1 <- proc.time()
    fiti=cv.glmnet(x,y, family="gaussian", alpha=1,foldid=foldid)
    m2ftime <- proc.time() - m2ftime1+ebtime
    beta1j=fiti$glmnet.fit$beta[,which.min(fiti$cvm)]
    
    ## APML0
    m4ftime1 <- proc.time()
    fiti=APML0(x, y, alpha=1,family="gaussian",foldid=foldid)
    m4ftime <- proc.time() - m4ftime1+ebtime
    beta2i=fiti$Beta
    beta2j=fiti$Beta0
 

    snpa2=which(beta1j!=0)
    #snpb1=which(beta2i!=0)
    snpb2=which(beta2j!=0)

    
    GLMa2=c(m2ftime[3],snpa2,beta1j[snpa2])
    #APML0bl=c(m4ftime[3],snpb1,beta2i[snpb1])
    APML0b2=c(m4ftime[3],snpb2,beta2j[snpb2])
    
   output = list(lasso=GLMa2,apml0=APML0b2)
  } 
  return(output)
}
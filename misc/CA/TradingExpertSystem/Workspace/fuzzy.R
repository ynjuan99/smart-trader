source("D:/et/commonUtility.R")
addLibrary()

data = read.csv("workshop2A_processedData2.csv", stringsAsFactors=FALSE)
colnames(data)

# EIR (Effective Interest Rate) = Bank Rate - Inflation
data$SG.EIR = data$SGPRIME.weekly - data$SGINF.weekly
data$UK.EIR = data$UKPRIME.weekly - data$UKINF.weekly
data$US.EIR = data$USPRIME.weekly - data$USINF.weekly

# AIM (Average Index Momentum) 
# US - Avg of DGI and S&P
# SG - STI
# UK - FTSE
data$US.AIM = (data$DJI.weekly.momentum + data$S.P.weekly.momentum)/2
data$SG.AIM = data$STI.weekly.momentum
data$UK.AIM = data$FTSE.weekly.momentum

# PER (Predicted Exchange Rate by NN) 
data$SGD.USD.PER = data$SG.D.forward.week
data$UKP.USD.PER = data$P.D.forward.week
dataset = data[,c("US.EIR", "SGD.USD.PER", "SG.EIR", "US.AIM", "UK.EIR", "SG.AIM", "UK.AIM",
                  "UKP.USD.PER", "date")]
# install.packages("sets")
library(sets)

## set universe
sets_options("universe", seq(from = -20, to = 20, by = 0.1))
## set up fuzzy variables
variables <-    #cannot use tuple, cannot plot. using set, if same varnames , only 1 created.
  set(SG.EIR = fuzzy_partition(varnames = c(SG.EIR.Very.Negative = -5,
                                            SG.EIR.Negative = -2,
                                            SG.EIR.No.Change = 0,
                                            SG.EIR.Positive = 2,
                                            SG.EIR.Very.Positive = 5
                                          ), sd = 1.5),
      UK.EIR = fuzzy_partition(varnames = c(UK.EIR.Very.Negative = -5,
                                            UK.EIR.Negative = -2,
                                            UK.EIR.No.Change = 0,
                                            UK.EIR.Positive = 2,
                                            UK.EIR.Very.Positive = 5
                                            ), sd = 1.5),
      US.EIR = fuzzy_partition(varnames = c(US.EIR.Very.Negative = -5,
                                            US.EIR.Negative = -2,
                                            US.EIR.No.Change = 0,
                                            US.EIR.Positive = 2,
                                            US.EIR.Very.Positive = 5
                                            ), sd = 1.5),
      SG.AIM = fuzzy_variable(SG.AIM.Negative =
                               fuzzy_trapezoid(corners = c(-20, -20, 0, 0)),
                              SG.AIM.Positive =
                               fuzzy_trapezoid(corners = c(0, 0, 20, 20))),
      UK.AIM = fuzzy_variable(UK.AIM.Negative =
                               fuzzy_trapezoid(corners = c(-20, -20, 0, 0)),
                              UK.AIM.Positive =
                               fuzzy_trapezoid(corners = c(0, 0, 20, 20))),
      US.AIM = fuzzy_variable(US.AIM.Negative =
                               fuzzy_trapezoid(corners = c(-20, -20, 0, 0)),
                              US.AIM.Positive =
                               fuzzy_trapezoid(corners = c(0, 0, 20, 20))),
      SGD.USD.PER = fuzzy_variable(SGD.USD.PER.Negative =
                                      fuzzy_trapezoid(corners = c(-20, -20, 0, 0)),
                                    SGD.USD.PER.Positive =
                                      fuzzy_trapezoid(corners = c(0, 0, 20, 20))),
      UKP.USD.PER = fuzzy_variable(UKP.USD.PER.Negative =
                                      fuzzy_trapezoid(corners = c(-20, -20, 0, 0)),
                                    UKP.USD.PER.Positive =
                                      fuzzy_trapezoid(corners = c(0, 0, 20, 20))),
      out.SGD.USD = fuzzy_partition(varnames = c(out.SGD.USD.Negative.High = -10,
                                                 out.SGD.USD.Negative.Small = -5,
                                                 out.SGD.USD.No.Change = 0,
                                                 out.SGD.USD.Small = 5,
                                                 out.SGD.USD.High = 10                   
                                                 ),
                                    FUN = fuzzy_cone, radius = 5),
      out.UKP.USD = fuzzy_partition(varnames = c(out.UKP.USD.Negative.High = -10,
                                                 out.UKP.USD.Negative.Small = -5,
                                                 out.UKP.USD.No.Change = 0,
                                                 out.UKP.USD.Small = 5,
                                                 out.UKP.USD.High = 10                   
                                                ),
                                    FUN = fuzzy_cone, radius = 5)
  )
## set up rules
df.rules <- read.csv("rules.csv", stringsAsFactors = FALSE, na.strings=c("NA",""))
df.rules.4 <- !is.na(df.rules$US.EIR) & 
                 !is.na(df.rules$SGD.USD.PER) &
                 !is.na(df.rules$SG.EIR) &
                 !is.na(df.rules$US.AIM)
df.rules.3 <- !is.na(df.rules$US.EIR) & 
                !is.na(df.rules$SGD.USD.PER) &
                !is.na(df.rules$SG.EIR) &
                is.na(df.rules$US.AIM)
df.rules.2 <- !is.na(df.rules$US.EIR) & 
                !is.na(df.rules$SGD.USD.PER) &
                is.na(df.rules$SG.EIR) &
                is.na(df.rules$US.AIM)
df.rules$rule[df.rules.4] <- 
  paste("fuzzy_rule(US.EIR %is% US.EIR.",df.rules[df.rules.4,"US.EIR"]," && ",
    "SGD.USD.PER %is% SGD.USD.PER.",df.rules[df.rules.4,"SGD.USD.PER"]," && ",
    "SG.EIR %is% SG.EIR.",df.rules[df.rules.4,"SG.EIR"]," && ",
    "US.AIM %is% US.AIM.",df.rules[df.rules.4,"US.AIM"],", ",
    "out.SGD.USD %is% out.SGD.USD.",df.rules[df.rules.4,"out.SGD.USD"],")",sep="") 
df.rules$rule[df.rules.3] <- 
  paste("fuzzy_rule(US.EIR %is% US.EIR.",df.rules[df.rules.3,"US.EIR"]," && ",
        "SGD.USD.PER %is% SGD.USD.PER.",df.rules[df.rules.3,"SGD.USD.PER"]," && ",
        "SG.EIR %is% SG.EIR.",df.rules[df.rules.3,"SG.EIR"],", ",
        "out.SGD.USD %is% out.SGD.USD.",df.rules[df.rules.3,"out.SGD.USD"],")",sep="") 
df.rules$rule[df.rules.2] <- 
  paste("fuzzy_rule(US.EIR %is% US.EIR.",df.rules[df.rules.2,"US.EIR"]," && ",
        "SGD.USD.PER %is% SGD.USD.PER.",df.rules[df.rules.2,"SGD.USD.PER"],", ",
        "out.SGD.USD %is% out.SGD.USD.",df.rules[df.rules.2,"out.SGD.USD"],")",sep="") 
rules <- 
  eval(parse(text=paste("set(",paste(df.rules$rule,collapse=","),")",sep=""))) 

rules <-
  set(
    fuzzy_rule(antecedent = (US.EIR %is% US.EIR.Very.Positive ||     #1
                                US.EIR %is% US.EIR.Positive) && 
                               SGD.USD.PER %is% SGD.USD.PER.Negative &&
                 SG.EIR %is% SG.EIR.Very.Negative && 
                 US.AIM %is% US.AIM.Positive,     
                 consequent = out.SGD.USD %is% out.SGD.USD.High),
    fuzzy_rule((US.EIR %is% US.EIR.Very.Positive ||                 #2
                  US.EIR %is% US.EIR.Positive) &&              
                 SGD.USD.PER %is% SGD.USD.PER.Negative &&
                 SG.EIR %is% SG.EIR.Very.Negative && 
                 US.AIM %is% US.AIM.Negative,
               out.SGD.USD %is% out.SGD.USD.Small),
    fuzzy_rule((US.EIR %is% US.EIR.Very.Positive ||                 #3
                  US.EIR %is% US.EIR.Positive) &&              
                 SGD.USD.PER %is% SGD.USD.PER.Negative &&
                 (SG.EIR %is% SG.EIR.Negative || 
                    SG.EIR %is% SG.EIR.No.Change),
               out.SGD.USD %is% out.SGD.USD.Small),
    fuzzy_rule(antecedent = (US.EIR %is% US.EIR.Very.Positive ||     #4
                               US.EIR %is% US.EIR.Positive) && 
                 SGD.USD.PER %is% SGD.USD.PER.Positive &&
                 SG.EIR %is% SG.EIR.Very.Negative && 
                 US.AIM %is% US.AIM.Positive,     
               consequent = out.SGD.USD %is% out.SGD.USD.Small),
    fuzzy_rule(antecedent = US.EIR %is% US.EIR.Very.Negative &&         #5
                 SGD.USD.PER %is% SGD.USD.PER.Positive &&
                 (SG.EIR %is% SG.EIR.Very.Positive ||
                    SG.EIR %is% SG.EIR.Positive) &&
                 US.AIM %is% US.AIM.Negative,     
               consequent = out.SGD.USD %is% out.SGD.USD.Negative.High),
    fuzzy_rule(antecedent = US.EIR %is% US.EIR.Very.Negative &&           #6
                 SGD.USD.PER %is% SGD.USD.PER.Positive &&
                 (SG.EIR %is% SG.EIR.Very.Positive ||
                    SG.EIR %is% SG.EIR.Positive) &&
                 US.AIM %is% US.AIM.Positive,     
               consequent = out.SGD.USD %is% out.SGD.USD.Negative.Small),
    fuzzy_rule(antecedent = (US.EIR %is% US.EIR.Negative || 
                               US.EIR %is% US.EIR.No.Change) &&           #7
                 SGD.USD.PER %is% SGD.USD.PER.Positive &&
                 (SG.EIR %is% SG.EIR.Very.Positive ||
                    SG.EIR %is% SG.EIR.Positive),     
               consequent = out.SGD.USD %is% out.SGD.USD.Negative.Small),
    fuzzy_rule(antecedent = US.EIR %is% US.EIR.Very.Negative &&           #8
                 SGD.USD.PER %is% SGD.USD.PER.Negative &&
                 (SG.EIR %is% SG.EIR.Very.Positive ||
                    SG.EIR %is% SG.EIR.Positive) &&
                 US.AIM %is% US.AIM.Negative,     
               consequent = out.SGD.USD %is% out.SGD.USD.Negative.Small)
    
  )
## combine to a system
system <- fuzzy_system(variables, rules)
print(system)
plot(system) ## plots variables
## do inference
fi <- fuzzy_inference(system, as.list(round(dataset[2,-9])))
fi <- fuzzy_inference(system, list(US.EIR = 5, SGD.USD.PER = -3,
                                   SG.EIR = -5, US.AIM = 3)) #1
fi <- fuzzy_inference(system, list(US.EIR = -5, SGD.USD.PER = -3,
                                   SG.EIR = 5, US.AIM = -10)) #2
## plot resulting fuzzy set
plot(fi)
## defuzzify
gset_defuzzify(fi, "centroid")
## reset universe
sets_options("universe", NULL)

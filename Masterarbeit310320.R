#install.packages("installr")
#library(installr)
#updateR()
###############################
###Install and load packages###
###############################
#install.packages("dummies")
#install.packages('plotly')
#install.packages('ggthemes')
#install.packages('dplyr')
#install.packages('plyr')
#install.packages('tidyr')
#install.packages('yaml')
#install.packages('lmtest')
#install.packages("pbkrtest")
#library(pbkrtest)
#install.packages('car')
#install.packages('foreign')
#install.packages('forcats')
#install.packages('ggplot2')
#install.packages("parameters")
#install.packages("performance")
#install.packages("devtools")
#require(devtools)
#install_version("car", version = "3.0-6", repos = "http://cran.us.r-project.org")
#install.packages("car")
#install.packages("glue")
#install.packages("lmtest")
#install.packages("lubridate")
#install.packages("RCurl")
#install.packages("tidyverse")
#install.packages("clubSandwich")
#install.packages("performance")
#install.packages("plm")

#update.packages()

#MetaAnalysePackages
#library(compute.es)# TO COMPUTE EFFECT SIZES
#library(MAd) # META-ANALYSIS PACKAGE
#install.packages("metafor")
#library(metafor) # META-ANALYSIS PACKAGE
load_packages <- function(x){
  #Read full Coding Excel file Packages
  library(readxl)
  #Data cleaning & analysing
  library(dplyr)
  library(plyr)
  library(tidyr)
  #Dummyfication
  library(dummies)
  #Visualization
  library(ggplot2)
  library(ggthemes)
  library(plotly)
  #Date & time processing
  library(lubridate)
  #Regression & statistical tests
  library(lmtest)
  library(car)
  # load necessary packages for importing the function
  library(RCurl)
  library(parameters)
  library(tidyverse)
  library(nlme)
  library(sandwich)
  library(clubSandwich)
  library(performance)
  library(multiwayvcov)
  library(ggpubr)
}
load_packages()

as_tibble(installed.packages()[,c(1,3)]) %>% write_csv(path = "packageList.csv")

# import the robust standard error function
url_robust <- "https://raw.githubusercontent.com/IsidoreBeautrelet/economictheoryblog/master/robust_summary.R"
eval(parse(text = getURL(url_robust, ssl.verifypeer = FALSE)),
     envir=.GlobalEnv)

varianz <- function(x) {n=length(x) ; var(x) * (n-1) / n}
stddev <- function(x) {n=length(x) ; sqrt(var(x) * (n-1) / n)}
#Multi Cluster Standard Error function - Following Mahmood Arais approach
mclx <- function(fm, dfcw, cluster1, cluster2){
  library(sandwich)
  library(lmtest)
  cluster12 = paste(cluster1,cluster2, sep="")
  M1 <- length(unique(cluster1))
  M2 <- length(unique(cluster2))
  M12 <- length(unique(cluster12))
  N <- length(cluster1)
  K <- fm$rank
  dfc1 <- (M1/(M1-1))*((N-1)/(N-K))
  dfc2 <- (M2/(M2-1))*((N-1)/(N-K))
  dfc12 <- (M12/(M12-1))*((N-1)/(N-K))
  u1 <- apply(estfun(fm), 2, function(x) tapply(x, cluster1, sum))
  u2 <- apply(estfun(fm), 2, function(x) tapply(x, cluster2, sum))
  u12 <- apply(estfun(fm), 2, function(x) tapply(x, cluster12, sum))
  vc1 <- dfc1*sandwich(fm, meat=crossprod(u1)/N )
  vc2 <- dfc2*sandwich(fm, meat=crossprod(u2)/N )
  vc12 <- dfc12*sandwich(fm, meat=crossprod(u12)/N)
  vcovMCL <- (vc1 + vc2 - vc12)*dfcw
  coeftest(fm, vcovMCL)}

xlsxreader <- function(path, sheet){
  read_excel(path, sheet = sheet, col_types = c("numeric", "numeric", "numeric",
                                                "text", "text", "text", "text", "text",
                                                "text", "text", "text", "text", "text", "numeric", "numeric",
                                                "text", "text", "text", "numeric", "numeric", "numeric", 
                                                "numeric",
                                                "numeric", "numeric", "text", "text",
                                                "text", "text", "numeric", "numeric", "text",
                                                "text", "text", "text", "date",
                                                "date", "text", "numeric", "text",
                                                "numeric", "text", "numeric", "numeric",
                                                "numeric", "numeric", "text", "text", "numeric",
                                                "numeric", "numeric", "numeric",
                                                "numeric", "numeric", "numeric",
                                                "numeric", "text", "numeric",
                                                "text", "text"))
}

###############################################
###Load Excel data, Setup & Adjust Dataframe###
###############################################
#load_df <- function(){
path <- "E:/02 temp/R Code/Coding_MH_260320.xlsx"
path2 <- "E:/02 temp/R Code/Übersicht Paper.xlsx"

#path <- "R Code/Coding_MH_190220.xlsx"
#path2 <- "R Code/Übersicht Paper.xlsx"

sheetnames <- excel_sheets(path)

df_codefile <- xlsxreader(path, 1)


for(i in 2:length(sheetnames)){
  df_temp <- xlsxreader(path, i)
  df_codefile <- rbind(df_codefile,df_temp)
}

###Daten über Paper hinzufügen
df_paper <- read_excel(path2, sheet = "Paper", 
                       col_types = c("numeric", "text", "text", "text", "text", "numeric", 
                                     "text", "text", "text", "text", "numeric", "numeric", "numeric", 
                                     "numeric", "numeric", "date", "date", "numeric", "numeric", "text"))

df_coded <- merge(df_codefile, df_paper, by=1)

###Replikate löschen

df_coded$repl[is.na(df_coded$repl)] <- 0
df_coded <- filter(df_coded, repl == 0)

df_coded$omitted[is.na(df_coded$omitted)] <- 0
df_coded <- filter(df_coded, omitted == 0)

###Nicht benötigte Spalten löschen

df_coded["x_var"] <- NULL
df_coded["y_var"] <- NULL
df_coded["y_var"] <- NULL
df_coded["data_typ"] <- NULL
df_coded["commodity_id"] <- NULL
df_coded["country_id"] <- NULL
df_coded["ic_id"] <- NULL
df_coded["x_dgp"] <- NULL
df_coded["y_dgp"] <- NULL
df_coded["integ"] <- NULL
df_coded["coint"] <- NULL
df_coded["ooi"] <- NULL
df_coded["dgp_uni"] <- NULL
df_coded["dgp_bi"] <- NULL
df_coded["dgp_multi"] <- NULL
df_coded["omitted_com"] <- NULL
df_coded["studyid"] <- NULL
df_coded["studyname"] <- NULL
df_coded["titel"] <- NULL
df_coded["Lehrstuhl?"] <- NULL
df_coded["recieved"] <- NULL
df_coded["accepted"] <- NULL

#distinct(df_coded, commodity_name)


###Anpassung der Daten
##GROUPER
###ACHTUNG SPEKULATION IST NUR NC, C SIND COMMERZIALS
pos_spec <- list("posabd", "posucb", "posncb", "poscf", 
                 "sumposnc", "sposnc", "lposnc", "posnc", "posncfao", "lposnc/lpos", "sposnc/spos", "posnc/(sposnc+lposnc)",
                 "posnc / n observations", "possd", "posncsd", "posncsdfao",
                 "poshf", "poshffao", 
                 "posfbt", "posfbtfao", 
                 "lpossd", "possdfao", 
                 "posmm", "lposmm",
                 "posii", "poslsp", 
                 "poscit", "posncit","lposcit", "poscitmm", "poscit/lpos", "lcitnv", 
                 "posfo", "posfofao",
                 "lposcit, return", "poscit, return",
                 "tindex",
                 "sposmm/oi", "lposs/oi", "lposmm/oi",
                 "posetf", "posetfnv", "cposetf")

pos_hedge <- list("posc", "lposc", "lposc/lpos", "sposc", "sposc/spos", "posc / n observations", "poscfao", 
                  "posp", "pospfao", "lposp",
                  "posma", "posmafao", 
                  "posdm", "posdmfao", 
                  "pospm", "posh")
pos_diverse <- list("posall", "pos", "lpost", "lpos", "spos", "pos/oi", "pos/oisl", 
                    "posnr", "lposnr", "posnrfao", "posnr / n observations",
                    "pos/oimml", "pos/oimms", "num")
oi <- list("goi", "oicit", "oicit/oi", "oi/volume", "uoi", "oi/pp", "oi", "oi/num", "loicit")
hm <- list("hmsd", "hmdm", "hmma", "hmfbt", "hmall", "hmhf")
vola <- list("cvola", "ivola", "vola", "rvola")
volume <- list("volume", "uevolume", "volume/oi", "uvolume", "uvolumeoi", "volume + uoi")
real <- list("expinv", "impinv", "inv", "gdp", "er", "ms", "oecdstock", "oecdspare", "oilrig", "oilstock", "wti")
return <- list("return", "returnfao", "roll return", "variance return")
other_spec <- list("aspec", "espec", "inefspec", "variance growth", "flow")
other_market <- list("spread", "liqui")
other <- list("fund rolling")

#effect_typ
#df_coded$effect_typ <- ifelse(is.na(df_coded$effect_typ), "n", df_coded$effect_typ)


#lev_dif
#df_coded$lev_dif <- ifelse(is.na(df_coded$lev_dif), "n", df_coded$lev_dif)

#func_form
#df_coded$func_form <- ifelse(is.na(df_coded$func_form), "n", df_coded$func_form)


#dcontemporaneouse (rein gehackt)
contemp4dataid_list <- list(1:32)
contemp9dataid_list <- list(1:14)
contemp16dataid_list <- list(3, 4, 7, 8, 11, 12, 15, 16)
contemp22dataid_list <- list(13:24)
contemp53dataid_list <- list(1:14)
contemp63dataid_list <- list(1:23)

df_coded$dcontemp  <- 0
df_coded$dcontemp  <- ifelse(df_coded$study_id == 4 & df_coded$data_id %in% contemp4dataid_list, 1, df_coded$dcontemp)
df_coded$dcontemp  <- ifelse(df_coded$study_id == 9 & df_coded$data_id %in% contemp9dataid_list, 1, df_coded$dcontemp)
df_coded$dcontemp  <- ifelse(df_coded$study_id == 16 & df_coded$data_id %in% contemp16dataid_list, 1, df_coded$dcontemp)
df_coded$dcontemp  <- ifelse(df_coded$study_id == 22 & df_coded$data_id %in% contemp22dataid_list, 1, df_coded$dcontemp)
df_coded$dcontemp  <- ifelse(df_coded$study_id == 53 & df_coded$data_id %in% contemp53dataid_list, 1, df_coded$dcontemp)
df_coded$dcontemp  <- ifelse(df_coded$study_id == 63 & df_coded$data_id %in% contemp63dataid_list, 1, df_coded$dcontemp)

#X-Var-Anpassung
df_coded$x <- ifelse(df_coded$x %in% pos_spec, "gpos_spec", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% pos_hedge, "gpos_hedge", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% pos_diverse, "gpos_diverse", df_coded$x)

df_coded$x <- ifelse(df_coded$x %in% oi, "goi", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% hm, "ghm", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% vola, "gvola", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% volume, "gvolume", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% real, "greal", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% return, "greturn", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% other_spec, "gother_spec", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% other_market, "gother_market", df_coded$x)
df_coded$x <- ifelse(df_coded$x %in% other, "gother", df_coded$x)

#X-Var-Anpassung
df_coded$y <- ifelse(df_coded$y %in% pos_spec, "gpos_spec", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% pos_hedge, "gpos_hedge", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% pos_diverse, "gpos_diverse", df_coded$y)

df_coded$y <- ifelse(df_coded$y %in% oi, "goi", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% hm, "ghm", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% vola, "gvola", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% volume, "gvolume", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% real, "greal", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% return, "greturn", df_coded$y)

df_coded$y <- ifelse(df_coded$y %in% other_spec, "gother_spec", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% other_market, "gother_market", df_coded$y)
df_coded$y <- ifelse(df_coded$y %in% other, "gother", df_coded$y)

#x-data-source
cftc <- list("cftc", "cftc cot", "cftc ltrs", "ltrs cftc", "cftc cot / dcot", 
             "cftc dcot", "cftc supplementary", "cftc scit", "cftc scot", "cftc cot, cftc scot", "cot")
spot <- list("spot market in indore", "spot market in kochi", "spot market in agra", "spot market in delhi",
             "spot market in jodhpur", "spot market in nagar")
bloomberg <- list("s&p gsci bloomberg", "bloomberg s&p gsci", "bloomberg")

df_coded$x_data_source <- ifelse(df_coded$x_data_source %in% cftc, "gcftc", df_coded$x_data_source)
df_coded$x_data_source <- ifelse(df_coded$x_data_source %in% spot, "gspot", df_coded$x_data_source)
df_coded$x_data_source <- ifelse(df_coded$x_data_source %in% bloomberg, "gbloomberg", df_coded$x_data_source)

#y-data-source
df_coded$y_data_source <- ifelse(df_coded$y_data_source %in% cftc, "gcftc", df_coded$y_data_source)
df_coded$y_data_source <- ifelse(df_coded$y_data_source %in% spot, "gspot", df_coded$y_data_source)
df_coded$y_data_source <- ifelse(df_coded$y_data_source %in% bloomberg, "gbloomberg", df_coded$y_data_source)

#Commodity_name group
#oil <- list("brent", "gasoline", "heating oil", "nymex heating oil", "nymex wti", "rbob gasoline",  "crude oil", "wti", "unleaded gas", "light sweet crude oil")
metal <- list("aluminium", "copper", "gold", "lead", "metals and minerals", "nickel", "palladium", "platinum", "silver", "tin", "zinc")
#gas <- list("natural gas", "nymex natural gas")
energy <- list("natural gas", "nymex natural gas", "brent", "gasoline", "heating oil", "nymex heating oil", "nymex wti", "rbob gasoline", "crude oil", "wti", "unleaded gas", "light sweet crude oil")
softcommodity <- list("agricultural raw materials", "barley", "beverages", "castor seed", "cbot corn", "cbot soybean", "cbot soybean oil", "cbot wheat", "chana", "chilli", 
                      "cluster bean (guar seed)", "cme feeder cattle", "cme lean hog", "cme live cattle", "cocoa", "coffee", "corn", "cotton", "feeder cattle", "food", 
                      "guar seed", "ice cocoa", "ice coffee", "ice cotton", "ice sugar", "ice us cotton", "ice us sugar", "jeera", "kcbot wheat", "kcbot hard red winter wheat", 
                      "lean hog", "live cattle", "live hog", "maize", "mastard seed", "mentha oil", "mge wheat", "mgex wheat", "mustard seed", "oats", "orange juice", "palm oil",
                      "pepper", "potato", "rapeseed oil", "refined soybean oil", "rice", "soybean", "soybean meal", "soybean oil", "soybean", "soybean oil", "sugar", "turmeric", "wheat",
                      "cotton (kapas)", "refined soy oil", "lumber", "soybean, soybean oil", "rubber", "cbot oats", "oil and fat", "grain")
financials <- list("fund", "eurodollar", "mini-dow", "eminidow", "non-energy index", "dollar exchange rate index", "equity index", "index")

#df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% oil, "goil", df_coded$commodity_name)
df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% metal, "gmetal", df_coded$commodity_name)
#df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% gas, "ggas", df_coded$commodity_name)
df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% energy, "genergy", df_coded$commodity_name)
df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% softcommodity, "gsoft", df_coded$commodity_name)
df_coded$commodity_name <- ifelse(df_coded$commodity_name %in% financials, "gfinancials", df_coded$commodity_name)

#System variable excluded because it can't be matched with no commodity
df_coded <- filter(df_coded, commodity_name != "system")

#financials excluded because the can't be matched with no commodity
df_coded <- filter(df_coded, commodity_name != "gfinancials")


#m Lag normalisation - on daily base - ohne HFT
#df_coded$tm <- ifelse(df_coded$period == "weekly", df_coded$m*5, df_coded$m)
#df_coded$tm <- ifelse(df_coded$period == "monthly", df_coded$m*20, df_coded$m)
#df_coded$tm <- ifelse(df_coded$period == "quarterly", df_coded$m*20*3, df_coded$m)

#m Lag normalisation - on quarterly base
df_coded$tm <- ifelse(is.na(df_coded$m), 0, df_coded$m)
df_coded$tm <- ifelse(df_coded$period == "5 min", df_coded$m/6/2/24/5/4/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "30 min", df_coded$m/2/24/5/4/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "60 min", df_coded$m/24/5/4/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "daily", df_coded$m/5/4/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "weekly", df_coded$m/4/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "monthly", df_coded$m/3, df_coded$tm)
df_coded$tm <- ifelse(df_coded$period == "quarterly", df_coded$m/1, df_coded$tm)

#n Lag normalisation - on daily base - ohne HFT
#df_coded$tn <- ifelse(df_coded$period == "weekly", df_coded$n*5, df_coded$m)
#df_coded$tn <- ifelse(df_coded$period == "monthly", df_coded$n*20, df_coded$m)
#df_coded$tn <- ifelse(df_coded$period == "quarterly", df_coded$n*20*3, df_coded$m)

#n Lag normalisation - on quarterly base
df_coded$tn <- ifelse(is.na(df_coded$n), 0, df_coded$n)
df_coded$tn <- ifelse(df_coded$period == "5 min", df_coded$n/6/2/24/5/4/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "30 min", df_coded$n/2/24/5/4/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "60 min", df_coded$n/24/5/4/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "daily", df_coded$n/5/4/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "weekly", df_coded$n/4/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "monthly", df_coded$n/3, df_coded$tn)
df_coded$tn <- ifelse(df_coded$period == "quarterly", df_coded$n/1, df_coded$tn)

#o Lag (zvar) normalisation - on quarterly base
df_coded$to <- ifelse(is.na(df_coded$o), 0, df_coded$o)
df_coded$to <- ifelse(df_coded$period == "5 min", df_coded$o/6/2/24/5/4/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "30 min", df_coded$o/2/24/5/4/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "60 min", df_coded$o/24/5/4/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "daily", df_coded$o/5/4/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "weekly", df_coded$o/4/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "monthly", df_coded$o/3, df_coded$to)
df_coded$to <- ifelse(df_coded$period == "quarterly", df_coded$o/1, df_coded$to)

#Func Typ
lineargc_list <- list("standard gc", "ty gc", "instantaneous gc", "dl gc", "ecm", "eg gc", "instantaneous gc", "panel gc") ###MUSS NOCHMAL ANGEPASST WERDEN!###
nonparagc_list <- list("dp gc", "vf-dp gc", "bb gc", "hj gc") ###MUSS NOCHMAL ANGEPASST WERDEN!###
quantile_list <- list("chuang gc") ###MUSS NOCHMAL ANGEPASST WERDEN!###
multivariate_list <- list("multivar gc", "multivariat gc")

df_coded$func_typ <- ifelse(df_coded$func_typ %in% lineargc_list, "glinear", df_coded$func_typ)
df_coded$func_typ <- ifelse(df_coded$func_typ %in% nonparagc_list, "gnonparametric", df_coded$func_typ)
df_coded$func_typ <- ifelse(df_coded$func_typ %in% quantile_list, "gquantile", df_coded$func_typ)
df_coded$func_typ <- ifelse(df_coded$func_typ %in% multivariate_list, "gmultivariate", df_coded$func_typ)

#Paper type
working_online_paper <- list("book / working paper", "First Draft, SSRN", "MPRA", "SSRN", "working paper", "working paper, SSRN")
conference_workshop_paper <- list("book / conference paper", "conference paper", "workshop paper")
discussion_paper <- list("discussion paper")

df_coded$type <- ifelse(df_coded$type %in% working_online_paper, "gworking_online_paper", df_coded$type)
df_coded$type <- ifelse(df_coded$type %in% conference_workshop_paper, "gconference_workshop_paper", df_coded$type)
df_coded$type <- ifelse(df_coded$type %in% discussion_paper, "gdiscussion_paper", df_coded$type)

#############
###Dummies###
#############
df_coded$dmetal <- ifelse(df_coded$commodity_name == "gmetal", 1, 0)
df_coded$denergy <- ifelse(df_coded$commodity_name == "genergy", 1, 0)
df_coded$dsoft <- ifelse(df_coded$commodity_name == "gsoft", 1, 0)
df_coded$dfinancial <- ifelse(df_coded$commodity_name == "gfinancials", 1, 0)

#Degrees of freedom
#M lags
log_list <- list("log-?", "log-lin", "log-log")
lin_list <- list("?-log", "lin-log", "linear")
df_coded$dlog <- ifelse(df_coded$func_form %in% log_list, 1, 0)
df_coded$dlin <- ifelse(df_coded$func_form %in% lin_list, 1, 0)
df_coded$dfstat <- ifelse(df_coded$effect_typ == "f-statistic", 1, 0)
df_coded$dchi2 <- ifelse(df_coded$effect_typ == "chi2", 1, 0)
df_coded$dtstat <- ifelse(df_coded$effect_typ == "t-statistic", 1, 0)
df_coded$dzstat <- ifelse(df_coded$effect_typ == "z", 1, 0)
df_coded$dlev <- ifelse(df_coded$lev_dif == "lev", 1, 0)
df_coded$ddif <- ifelse(df_coded$lev_dif == "dif", 1, 0)
varvec_list <- list("var", "vec", "sur", "vecm", "ols")
df_coded$dvarvec <- ifelse(df_coded$system %in% varvec_list, 1, 0)
adl_list <- list("adl", "ardl")
df_coded$dadl <- ifelse(df_coded$system %in% adl_list, 1, 0)
df_coded$dzvar <- ifelse(is.na(df_coded$z_var), 0, 1)
df_coded$dlineargc <- ifelse(df_coded$func_typ == "glinear", 1, 0)
df_coded$dnonparagc <- ifelse(df_coded$func_typ == "gnonparametric", 1, 0)
df_coded$dquantilegc <- ifelse(df_coded$func_typ == "gquantile", 1, 0)
df_coded$dmultivariategc <- ifelse(df_coded$func_typ == "gmultivariate", 1, 0)
#df_coded$dcontemp 
#df_coded$daic <- ifelse(df_coded$ic == "aic", 1, 0)
#df_coded$daic <- ifelse(is.na(df_coded$ic), 0, df_coded$daic)
#df_coded$dbic <- ifelse(df_coded$ic == "bic", 1, 0)
#df_coded$dbic <- ifelse(is.na(df_coded$ic), 0, df_coded$dbic)
aicplus <- list("aic", "aic, bic", "aic, bic, hq", "aic, fpe", "aic, fpe, hq, lr", "aic, hq, bic",
                "aic, hq, sic", "aic, sic", "modified lr test, final prediction error, aic, bic, hq",
                "sic, aic")
bicplus <- list("bic", "aic, bic", "aic, bic, hq", "aic, hq, bic", "aic, hq, sic", "aic, sic", 
                "modified lr test, final prediction error, aic, bic, hq", "ng-perron, sic", "sic", "sic, aic")
df_coded$daicplus <- ifelse(df_coded$ic %in% aicplus, 1, 0)
df_coded$daicplus <- ifelse(is.na(df_coded$ic), 0, df_coded$daicplus)
df_coded$dbicplus <- ifelse(df_coded$ic %in% bicplus, 1, 0)
df_coded$dbicplus <- ifelse(is.na(df_coded$ic), 0, df_coded$dbicplus)

aic <- list("aic", "aic, fpe", "aic, fpe, hq, lr")
bic <- list("bic", "ng-perron, sic", "sic")
aicbicplus <- list("aic, bic", "aic, bic, hq", "aic, hq, bic", "aic, hq, sic", "aic, sic", 
                   "modified lr test, final prediction error, aic, bic, hq", "sic, aic")
df_coded$dic <- ifelse(is.na(df_coded$ic), "other", "other")
df_coded$dic <- ifelse(df_coded$ic %in% aic, "aic", df_coded$dic)
df_coded$dic <- ifelse(df_coded$ic %in% bic, "bic", df_coded$dic)
df_coded$dic <- ifelse(df_coded$ic %in% aicbicplus, "aicbic", df_coded$dic)

adf <- list("adf", "adf-gls, zivot and andrews,  kejriwal and perron", "adf-gls, zivot and andrews, kejriwal and perron",
            "adf, ardl", "adf, chow test", "adf, engel-granger test", "adf, engle and granger test, johansen test", 
            "adf, kpss", "adf, kpss, lm, engle granger test, johansen", "adf, lm", "adf, newey-west correction", "df, ng-perron",
            "adf, pp", "adf, pp, ers", "adf, pp, lm", "adf, pp, np, kpss", "adf, zivot–andrews tests, clement–montañes–reyes tests",
            "adf, zivot and andrews", "johansen test, adf")
#df_coded$dadf <- ifelse(df_coded$pretest %in% adf, 1, 0)
df_coded$dcftc <- ifelse(df_coded$x_data_source == "gcftc" | df_coded$y_data_source == "gcftc", 1, 0)
df_coded$dcftc <- ifelse(is.na(df_coded$x_data_source) | is.na(df_coded$y_data_source), 0, df_coded$dcftc)
df_coded$dpretest <- ifelse(is.na(df_coded$pretest), 0, 1)
df_coded$dfuture <- ifelse(df_coded$x_sf == "f" | df_coded$y_sf == "f", 1, 0)
df_coded$daily <- ifelse(df_coded$period == "daily", 1, 0)
df_coded$weekly <- ifelse(df_coded$period == "weekly", 1, 0)
df_coded$monthly <- ifelse(df_coded$period == "monthly", 1, 0)
df_coded$quarterly <- ifelse(df_coded$period == "quarterly", 1, 0)
df_coded$avgyear <- (year(df_coded$startyear) + year(df_coded$endyear))/2
df_coded$d2007 <- ifelse(df_coded$avgyear-2007 >= 0, 1, 0)

df_coded$duration <- (year(df_coded$endyear)-year(df_coded$startyear))
#table(unlist(df_coded$duration))
#summary(df_coded$duration)
#table(unlist(df_coded$avgyear))
#table(unlist(df_coded$d2007))

#df_coded$pubyear <- year(as.Date(df_coded$pubyear))
df_coded$dinfluenced <- ifelse(is.na(df_coded$influenced), 0, 1)
df_coded$dtype <- ifelse(df_coded$type == "article", 1, 0)
df_coded$sjr2018 <- ifelse(is.na(df_coded$sjr2018), 0, df_coded$sjr2018)
df_coded$ajg2018 <- ifelse(is.na(df_coded$ajg2018), 0, df_coded$ajg2018)
df_coded$googlecits <- ifelse(is.na(df_coded$googlecits), 0, df_coded$googlecits)
df_coded$repec <- ifelse(is.na(df_coded$repec), 0, df_coded$repec)
df_coded$dsum <- ifelse(df_coded$hypothese_style == "sum", 1, 0)
df_coded$dsingle <- ifelse(df_coded$hypothese_style == "single", 1, 0)
df_coded$checker <- ifelse(df_coded$p_val >= df_coded$sign, 1, 0)
df_coded$ranking <- (df_coded$sjr2018/sum(df_coded$sjr2018) + df_coded$ajg2018/sum(df_coded$ajg2018) + df_coded$googlecits/sum(df_coded$googlecits)
                     + df_coded$repec/sum(df_coded$repec))/4
df_coded$dranking <- ifelse(df_coded$ranking >= quantile(df_coded$ranking, 0.75), 1, 0)
df_coded$dreturn <- ifelse(df_coded$y == "greturn" | df_coded$y == "price", 1, 0)
df_coded$dvola <- ifelse(df_coded$y == "gvola", 1, 0)

df_coded$doi <- ifelse(df_coded$x == "goi", 1, 0)
df_coded$dpos <- ifelse(df_coded$x == "gpos_spec", 1, 0)
df_coded$dvolume <- ifelse(df_coded$x == "gvolume", 1, 0)
df_coded$dpvalcalc <- ifelse(df_coded$x == "gvolume", 1, 0)

df_coded$ranking <- (df_coded$sjr2018/sum(df_coded$sjr2018) + df_coded$ajg2018/sum(df_coded$ajg2018) + df_coded$googlecits/sum(df_coded$googlecits)
                     + df_coded$repec/sum(df_coded$repec))/4
df_coded$dranking <- ifelse(df_coded$ranking >= quantile(df_coded$ranking, 0.75), 1, 0)
#samps_calc
studyid_calc_pval <- list(7, 18, 26, 34, 38, 47, 49) #Liste von Studien IDs von in Excel kalkulierten Daten
df_coded$dpvalcalc <- ifelse(df_coded$study_id %in% studyid_calc_pval, 1, 0)

#distinct(select(filter(df_all, is.na(dpvalcalc)), dpvalcalc, study_id), study_id, .keep_all = TRUE)
#str(df_all)
#studyid_pval_0 <- list(3,6,7,9,10,11,13,14,15,16,17,19,20,21,22,23,24,37,45,46,48,49,50,52,53,54,56,58,59,66,69,70)
#distinct(select(filter(df_all, is.na(p_val_calc)), p_val_calc, study_id), study_id, .keep_all = TRUE)


#############################
###Spec & market & hedging###
#############################
###CHECK BEFOR LISTS EXECUTION! 
#distinct(select(df_coded, x))
#distinct(select(df_coded, y))

#Combine small groups <50
df_coded$x <- ifelse(df_coded$x == "ghm", "gother_spec", df_coded$x) #<65 & spec therefor subsumed in other_spec
df_coded$x <- ifelse(df_coded$x == "tindex", "gother_spec", df_coded$x) #<65 & spec therefor subsumed in other_spec
df_coded$x <- ifelse(df_coded$x == "greal", "gother_market", df_coded$x) #<65 &market therefor subsumed in other_market
df_coded$x <- ifelse(df_coded$x == "index", "gother_market", df_coded$x) #<65 &market therefor subsumed in other_market
df_coded$x <- ifelse(df_coded$x == "priceshock", "gother_market", df_coded$x) #<65 &market therefor subsumed in other_market

df_coded$y <- ifelse(df_coded$y == "ghm", "gother_spec", df_coded$y) #<65 & spec therefor subsumed in other_spec
df_coded$y <- ifelse(df_coded$y == "tindex", "gother_spec", df_coded$y) #<65 & spec therefor subsumed in other_spec
df_coded$y <- ifelse(df_coded$y == "greal", "gother_market", df_coded$y) #<65 &market therefor subsumed in other_market
df_coded$y <- ifelse(df_coded$y == "index", "gother_market", df_coded$y) #<65 &market therefor subsumed in other_market
df_coded$y <- ifelse(df_coded$y == "priceshock", "gother_market", df_coded$y) #<65 &market therefor subsumed in other_market

#Lists of factor groups
spec_list <- list("gpos_spec", "goi", "ghm", "gvolume", "spec", "spread", "volume + uoi", "priceshock", "tindex", "num",
                  "liqui", "inefspec", "spec", "espec", "aspec", "gother_spec")
market_list <- list("greal", "greturn", "price", "flow", "gvola", "index", "priceshock", "index", "gother_market")
hedging_list <- list("gpos_hedge")
other_list <- list("gpos_diverse", "gother")

#Define Spec
df_coded$x_sm <- ifelse(df_coded$x %in% spec_list, "spec", "NA")
df_coded$y_sm <- ifelse(df_coded$y %in% spec_list, "spec", "NA")

#Define Market
df_coded$x_sm <- ifelse(df_coded$x %in% market_list, "market", df_coded$x_sm)
df_coded$y_sm <- ifelse(df_coded$y %in% market_list, "market", df_coded$y_sm)

#Define Hedge
df_coded$x_sm <- ifelse(df_coded$x %in% hedging_list, "hedge", df_coded$x_sm)
df_coded$y_sm <- ifelse(df_coded$y %in% hedging_list, "hedge", df_coded$y_sm)

#Define Hedge
df_coded$x_sm <- ifelse(df_coded$x %in% other_list, "other", df_coded$x_sm)
df_coded$y_sm <- ifelse(df_coded$y %in% other_list, "other", df_coded$y_sm)

#################################
###Handling of p-value 1 and 0###
#################################

#Option 1: Maximum version - tp_val
df_coded$tp_val <- df_coded$p_val
df_coded$tp_val[df_coded$p_val==0] <- 1e-180                #Other data points have p-value somewhere at 1e-150, thats why distance is needed
df_coded$tp_val[df_coded$p_val==1] <- 0.9999999999999999    #Highest p-value working with qnorm() 16 9er

#Option 2: Minimum version - t2p_val
df_coded$t2p_val <- df_coded$p_val

#decimalplaces <- function(x) {
#  if ((x %% 1) != 0) {
#    nchar(strsplit(sub('0+$', '', as.character(x)), ".", fixed=TRUE)[[1]][[2]])
#  } else {
#    return(0)
#  }
#}

#for (i in studyid_pval_0){
#  print(decimalplaces(select(filter(df_coded, study_id == i & data_id == 1), t2p_val)))
#}

df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==3] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==6] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==7] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==9] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==10] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==11] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==13] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==14] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==15] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==16] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==17] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==19] <- 0.000004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==20] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==21] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==22] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==23] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==24] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==34] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==37] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==43] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==45] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==46] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==48] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==49] <- 0.0000000000000000004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==50] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==52] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==53] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==54] <- 0.004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==56] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==58] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==59] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==66] <- 0.00004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==69] <- 0.0004   #Study specific - Highest value that would produce 0 after rounding
df_coded$t2p_val[df_coded$p_val==0 & df_coded$study_id==70] <- 0.004   #Study specific - Highest value that would produce 0 after rounding

df_coded$t2p_val[df_coded$p_val==1 & df_coded$study_id==6] <- 0.995   #Study specific - Lowest value that would produce 1 after rounding
df_coded$t2p_val[df_coded$p_val==1 & df_coded$study_id==22] <- 0.9995   #Study specific - Lowest value that would produce 1 after rounding
df_coded$t2p_val[df_coded$p_val==1 & df_coded$study_id==38] <- 0.949692369  #Study specific - Lowest value that would produce 1 after rounding, p-value was calculated from F-value 0.000, next possible F-value is 0.0004 and p-value for this is assumed 
df_coded$t2p_val[df_coded$p_val==1 & df_coded$study_id==49] <- 0.99960008   #Study specific - Lowest value that would produce 1 after rounding, p-value was calculated from F-value 0.000, next possible F-value is 0.0004 and p-value for this is assumed 

###################################
###Probit & square-root Funktion###
###################################
#Probit Model - p_val 0 & 1 cleared
df_coded$probit <- -qnorm(df_coded$p_val)
df_coded$probit <- ifelse(is.infinite(df_coded$probit), NA, df_coded$probit) #INF Probit Werte löschen

#tProbitModel - p_val 0 & 1 assumed by lowest & highest
df_coded$tprobit <- -qnorm(df_coded$tp_val)

#t2Probit Model - p_val 0 & 1 assumed by highest & lowest
df_coded$t2probit <- -qnorm(df_coded$t2p_val)

#df Model - Non normed lags
#Z Var & Contemp mit rein
#table(unlist(df_coded$z))
#distinct(select(filter(df_coded, z == "?"), study_id, data_id, z), data_id, .keep_all = TRUE)
df_coded$df <- df_coded$samps - df_coded$m - df_coded$n - df_coded$o      #Nicht normierte lags
df_coded$df <- df_coded$samps - rowSums(df_coded[,c('m', 'n', 'o')], na.rm=TRUE)      #Nicht normierte lags
#tdf Model - Normed lags
df_coded$tdf <- df_coded$samps-rowSums(df_coded[,c('tm', 'tn', 'to')], na.rm=TRUE)  #Normierte lags

#############################
###Calculation of variance###
#############################

df_coded$calc_var <- (df_coded$m + df_coded$n) * 
  ((((df_coded$df - (2*(df_coded$m + df_coded$n)) -1)^2) * (df_coded$df - (df_coded$m + df_coded$n) - 3))
   /(((df_coded$df - (2*(df_coded$m + df_coded$n)) - 3)^2) * (df_coded$df - (df_coded$m + df_coded$n) - 5)))

##########################
###Clean Dataset of NAs###
##########################

data_coded_na <- df_coded[ , c("samps", "p_val", "m", "n")]   #Exclude NAs for df, probit, m, n
#data_coded_na2 <- df_coded[ , c("samps", "p_val", "m")]   #Exclude NAs for df, probit, m, n
df_all <- df_coded[complete.cases(data_coded_na), ] # Omit NAs by columns
#df_all2 <- df_coded[complete.cases(data_coded_na2), ] # Omit NAs by columns

df_all <- filter(df_all, period != "5 min" & period != "30 min" & period !="60 min") #Exclude high frequency data

##################################
###Count observations per study###
##################################
###Caution! Calculates befor subset!!! Is recalculated after subset generation!
df_all$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_all, study_id == i))[1]
  df_all$studyobs <- ifelse(df_all$study_id == i, temp, df_all$studyobs)
}


########################
###Setup Data Subsets###
########################

###Erstelle Subset - all
#df_all <- filter(df_coded, func_typ != "multivariate gc" & effect_typ != "t-statistic")
#df_all <- filter(df_coded, func_typ != "multivariate gc")
#df_all <- filter(df_coded, effect_typ != "t-statistic")
#df_all <- filter(df_coded, period != "5 min" & period != "30 min" & period !="60 min" & effect_typ != "t-statistic")

#All -Exclude NA values
data_subset_all_norm <- df_all[ , c("df", "probit")] 
df_all_norm <- df_all[complete.cases(data_subset_all_norm), ] # Omit NAs by columns
data_subset_all_t <- df_all[ , c("df", "tprobit")] 
df_all_t <- df_all[complete.cases(data_subset_all_t), ] # Omit NAs by columns
data_subset_all_t2 <- df_all[ , c("df", "t2probit")] 
df_all_t2 <- df_all[complete.cases(data_subset_all_t2), ] # Omit NAs by columns

###S2M - Setup Subset & re-calculate studyobs
df_s2m <- filter(df_all, x_sm == "spec" & y_sm == "market")
df_s2m$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_s2m, study_id == i))[1]
  df_s2m$studyobs <- ifelse(df_s2m$study_id == i, temp, df_s2m$studyobs)
}
#S2M -Exclude NA values
data_subset_s2m_norm <- df_s2m[ , c("df", "probit")] 
df_s2m_norm <- df_s2m[complete.cases(data_subset_s2m_norm), ] # Omit NAs by columns
data_subset_s2m_t <- df_s2m[ , c("df", "tprobit")] 
df_s2m_t <- df_s2m[complete.cases(data_subset_s2m_t), ] # Omit NAs by columns
data_subset_s2m_t2 <- df_s2m[ , c("df", "t2probit")] 
df_s2m_t2 <- df_s2m[complete.cases(data_subset_s2m_t2), ] # Omit NAs by columns

###M2S - Setup Subset & re-calculate studyobs
df_m2s <- filter(df_all, x_sm == "market" & y_sm == "spec")
df_m2s$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_m2s, study_id == i))[1]
  df_m2s$studyobs <- ifelse(df_m2s$study_id == i, temp, df_m2s$studyobs)
}
#M2S -Exclude NA values
data_subset_m2s_norm <- df_m2s[ , c("df", "probit")] 
df_m2s_norm <- df_m2s[complete.cases(data_subset_m2s_norm), ] # Omit NAs by columns
data_subset_m2s_t <- df_m2s[ , c("df", "tprobit")] 
df_m2s_t <- df_m2s[complete.cases(data_subset_m2s_t), ] # Omit NAs by columns
data_subset_m2s_t2 <- df_m2s[ , c("df", "t2probit")] 
df_m2s_t2 <- df_m2s[complete.cases(data_subset_m2s_t2), ] # Omit NAs by columns

###H2M - Setup Subset & re-calculate studyobs
df_h2m <- filter(df_all, x_sm == "hedge" & y_sm == "market")
df_h2m$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_h2m, study_id == i))[1]
  df_h2m$studyobs <- ifelse(df_h2m$study_id == i, temp, df_h2m$studyobs)
}
#H2M -Exclude NA values
data_subset_h2m_norm <- df_h2m[ , c("df", "probit")] 
df_h2m_norm <- df_h2m[complete.cases(data_subset_h2m_norm), ] # Omit NAs by columns
data_subset_h2m_t <- df_h2m[ , c("df", "tprobit")] 
df_h2m_t <- df_h2m[complete.cases(data_subset_h2m_t), ] # Omit NAs by columns
data_subset_h2m_t2 <- df_h2m[ , c("df", "t2probit")] 
df_h2m_t2 <- df_h2m[complete.cases(data_subset_h2m_t2), ] # Omit NAs by columns

###M2H - Setup Subset & re-calculate studyobs
df_m2h <- filter(df_all, x_sm == "market" & y_sm == "hedge")
df_m2h$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_m2h, study_id == i))[1]
  df_m2h$studyobs <- ifelse(df_m2h$study_id == i, temp, df_m2h$studyobs)
}
#M2H -Exclude NA values
data_subset_m2h_norm <- df_m2h[ , c("df", "probit")] 
df_m2h_norm <- df_m2h[complete.cases(data_subset_m2h_norm), ] # Omit NAs by columns
data_subset_m2h_t <- df_m2h[ , c("df", "tprobit")] 
df_m2h_t <- df_m2h[complete.cases(data_subset_m2h_t), ] # Omit NAs by columns
data_subset_m2h_t2 <- df_m2h[ , c("df", "t2probit")] 
df_m2h_t2 <- df_m2h[complete.cases(data_subset_m2h_t2), ] # Omit NAs by columns


#}
#load_df()





############################
###Descriptive Statistics###
############################

###Count Num of obs per study & mean###
#ALL
count(df_all$study_id)
nrow(df_all)
summary(df_all$p_val)
summary(df_all$studyobs)
#S2M
count(df_s2m$study_id)
nrow(df_s2m)
summary(df_s2m$studyobs)
#M2S
count(df_m2s$study_id)
nrow(df_m2s)
summary(df_m2s$studyobs)
#H2M
count(df_h2m$study_id)
nrow(df_h2m)
summary(df_h2m$studyobs)
#M2H
count(df_m2h$study_id)
nrow(df_m2h)
summary(df_m2h$studyobs)

count(df_s2m$p_val)
table(unlist(df_s2m$study_id))
distinct(select(df_s2m, study_id, studyobs), study_id, .keep_all = TRUE)
distinct(select(df_s2m, study_id, studyobs), study_id, .keep_all = TRUE) %>% summary()

distinct(df_s2m, study_id) 

#################################
###Count x and y specification###
#################################

table(unlist(df_all$x))
table(unlist(df_all$y))

###Check why excluded
distinct(select(df_coded, study_id, m, n, samps), study_id, .keep_all = TRUE)
distinct(select(df_s2m, study_id, studyobs), study_id, .keep_all = TRUE)


##################################
###Barplots for commodity share###
##################################


df_s2m["Subset"] <- "S2M"
df_m2s["Subset"] <- "M2S"
df_comb <- rbind(df_m2s, df_s2m)
df_comb$commodity_name <- ifelse(df_comb$commodity_name =="genergy", "Energy", df_comb$commodity_name)
df_comb$commodity_name <- ifelse(df_comb$commodity_name =="gmetal", "Metal", df_comb$commodity_name)
df_comb$commodity_name <- ifelse(df_comb$commodity_name =="gsoft", "Soft Commodity", df_comb$commodity_name)

table(unlist(df_s2m$commodity_name))
table(unlist(df_m2s$commodity_name))

g <- ggplot(df_comb, aes(Subset))
g + geom_bar(aes(fill = commodity_name)) + labs(fill="Commodity") + scale_y_continuous(name="No. of results")

###############################
###Mean & Standard Deviation###
###############################

dummy_list <- list("df", "m", "dmetal", "denergy", "dsoft",  "dfstat", "dchi2","dtstat",
                   "dlev", "ddif", "dlin", "dlog",
                   "dvarvec", "dadl","dcontemp", "dsum", "dsingle", "dzvar", "dlineargc", "dnonparagc", "dquantilegc", 
                   "dmultivariategc", "daicplus", "dbicplus", "dpretest", "dcftc", "dfuture", 
                   "daily", "weekly", "monthly", "quarterly", "avgyear", "pubyear", "d2007", "dinfluenced", "dtype", 
                   "dranking", "samps_calc", "dpvalcalc",
                   "dreturn", "dvola", "doi", "dpos")


for (i in dummy_list){
  print(round(apply(df_s2m[i], 2, mean), 3)) 
  print(round(apply(df_s2m[i], 2, stddev), 3))
}

table(unlist(df_coded$commodity_name))

##########################
###Journal quality test###
##########################

model_journalquality <- lm(sqrt(df) ~ ranking, data = df_s2m) #OLS


summary(model_journalquality)

###Testing for Genuine effects
t(table(unlist(df_coded$p_val)))
table(unlist(df_coded$p_val))

##Scatterplot probit vs sqrt(DF)
#Teste probit auf NAN und NA
#distinct(select(filter(df_coded, probit=="NaN"), study_id, probit), study_id, .keep_all = TRUE)
#distinct(select(filter(df_coded, is.na(probit)), study_id, probit), study_id, .keep_all = TRUE)
#Teste df auf NAN und NA
#distinct(select(filter(df_coded, df=="NaN"), study_id, df), study_id, .keep_all = TRUE)
#distinct(select(filter(df_coded, is.na(df)), study_id, df), study_id, .keep_all = TRUE)

########################################
###Plot Scatterplott of probit vs. df###
########################################

g1 <- ggplot(df_s2m, aes(y=tprobit, x=sqrt(df))) + geom_point(aes(color=study_id), show.legend = FALSE) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2) + 
  scale_x_continuous(name="sqrt(DF)") + scale_y_continuous(name="-probit") + coord_cartesian(ylim=c(-3,30)) + ggtitle("Subset A")
g2 <- ggplot(df_s2m, aes(y=t2probit, x=sqrt(df))) + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2) + 
  scale_x_continuous(name="sqrt(DF)") + scale_y_continuous(name="-probit") + coord_cartesian(ylim=c(-3,30)) + ggtitle("Subset B")

ggarrange(g1, g2, common.legend = TRUE, legend = "right")

###Calculate distribution values
###Barplot StdN distribution & frequenze vs probit
##Barplot probit vs distribution - Für All

g3 <- ggplot(df_s2m, aes(x=tprobit)) + geom_histogram(aes(y=..density..), binwidth=0.5) + stat_function(fun = dnorm, color='blue') + 
  scale_x_continuous(name="-probit") + coord_cartesian(xlim=c(-3,30)) + 
  geom_vline(xintercept=1.65, color="red", linetype = 2) + ggtitle("Subset A")
g4 <- ggplot(df_s2m, aes(x=t2probit)) + geom_histogram(aes(y=..density..), binwidth=0.5) + stat_function(fun = dnorm, color='blue') + 
  scale_x_continuous(name="-probit") + coord_cartesian(xlim=c(-3,30)) + 
  geom_vline(xintercept=1.65, color="red", linetype = 2) + ggtitle("Subset B")

ggarrange(g3, g4, common.legend = TRUE, legend = "right")



#############################
###Investigation p-hacking###
#############################
df_phack <- filter(df_s2m, p_val <=0.1 & p_val >= 0)

#Linechart
g7 <- ggplot(df_s2m, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Full sample")
g8 <- ggplot(df_phack, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 0.1, 0.05), breaks = seq(0, 0.1, 0.05), expand = c(0.0001, 0.005)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Selected sample")
ggarrange(g7, g8, common.legend = TRUE, legend = "right")


##############################################################
###Barplot probit vs distribution - grouped for commodities###
##############################################################
#df_metal <- filter(df_all, commodity_name == "gmetal")
#pl_metal <- ggplot(data=df_s2m, aes(x=p_val))
#print(ggplotly(pl_metal + geom_histogram(aes(y=..count..)) + stat_function(fun = dnorm, color='red')))

#df_soft <- filter(df_all, commodity_name == "gsoft")
#df_energy <- filter(df_all, commodity_name == "genergy")
#df_energy <- filter(df_all, commodity_name == "gfinancial")

#pl_metal <- ggplot(data=df_metal, aes(x=p_val))
#print(ggplotly(pl_metal + geom_histogram(aes(y=..count..)) + stat_function(fun = dnorm, color='red')))

#pl1 <- ggplot(data=df_metal, aes(x=probit))
#print(ggplotly(pl1 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))

#distinct(df_metal, study_id)
#nrow(df_metal)

#################################################
###Investigation p-hacking - Commodity grouped###
#################################################
df_soft_t <- filter(df_s2m_t, commodity_name == "gsoft")
df_soft_t2 <- filter(df_s2m_t2, commodity_name == "gsoft")

df_energy_t <- filter(df_s2m_t, commodity_name == "genergy")
df_energy_t2 <- filter(df_s2m_t2, commodity_name == "genergy")

df_metal_t <- filter(df_s2m_t, commodity_name == "gmetal")
df_metal_t2 <- filter(df_s2m_t2, commodity_name == "gmetal")

g9  <- ggplot(df_soft_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Soft Commodity")
g10 <- ggplot(df_energy_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Energy")
g11 <- ggplot(df_metal_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Metal")

ggarrange(g9, g10, g11, common.legend = TRUE, legend = "right", nrow = 1)

##################################################
###Investigation p-hacking - Statistics grouped###
##################################################
df_tstat_t <- filter(df_s2m_t, effect_typ == "t-statistic")
df_tstat_t2 <- filter(df_s2m_t2, effect_typ == "t-statistic")

df_fstat_t <- filter(df_s2m_t, effect_typ == "f-statistic")
df_fstat_t2 <- filter(df_s2m_t2, effect_typ == "f-statistic")

df_chi2_t <- filter(df_s2m_t, effect_typ == "chi2")
df_chi2_t2 <- filter(df_s2m_t2, effect_typ == "chi2")

g12  <- ggplot(df_tstat_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("t-statistic")
g13 <- ggplot(df_fstat_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("F-statistic")
g14 <- ggplot(df_chi2_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Chi²-statistic")

ggarrange(g12, g13, g14, common.legend = TRUE, legend = "right", nrow = 1)

##################################################
###Investigation p-hacking - AvgYear 2007 - grouped###
##################################################
df_after2007_t <- filter(df_s2m_t, d2007 == 1)
df_after2007_t2 <- filter(df_s2m_t2, d2007 == 1)
df_before2007_t <- filter(df_s2m_t, d2007 == 0)
df_before2007_t2 <- filter(df_s2m_t2, d2007 == 0)

g <- ggplot(df_after2007_t, aes(x=tp_val))
g <- ggplot(df_after2007_t2, aes(x=t2p_val))
g <- ggplot(df_before2007_t, aes(x=tp_val))
g <- ggplot(df_before2007_t2, aes(x=t2p_val))

g + geom_histogram(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value") + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2)

g9  <- ggplot(df_soft_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Soft Commodity")
g10 <- ggplot(df_energy_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Energy")
g11 <- ggplot(df_metal_t2, aes(x=t2p_val)) + geom_density(aes(y=(..count..)/sum(..count..))) + scale_x_continuous(name="p-value", minor_breaks = seq(0, 1, 0.05), expand = c(0.00001, 0.05)) + 
  scale_y_continuous(name="Fraction") + geom_vline(xintercept=0.05, color="red", linetype = 2) + ggtitle("Metal")

ggarrange(g9, g10, g11, common.legend = TRUE, legend = "right", nrow = 1)


######################
####Basic MRA - S2M###
######################
#Subset A
model_s2m_t_1 <- lm(tprobit ~ sqrt(df), data = df_s2m_t)
HighLeverage <- cooks.distance(model_s2m_t_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t_1) > 3
df_s2m_t_1_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_1 <- lm(tprobit ~ sqrt(df), data = df_s2m_t1_f)
print(coeftest(hlmodel_s2m_t_1, cluster.vcov(hlmodel_s2m_t_1, cbind(df_s2m_t_1_hl$study_id, df_s2m_t_1_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t_2 <- lm(tprobit ~ sqrt(df), data = df_s2m_t, weights = sqrt(df)) #WLS sqrt(DF)
HighLeverage <- cooks.distance(model_s2m_t_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t_2) > 3
df_s2m_t_2_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_2 <- lm(tprobit ~ sqrt(df), data = df_s2m_t_2_hl, weights = sqrt(df)) #WLS sqrt(DF)
print(coeftest(hlmodel_s2m_t_2, cluster.vcov(hlmodel_s2m_t_2, cbind(df_s2m_t_2_hl$study_id, df_s2m_t_2_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t_3 <- lm(tprobit ~ sqrt(df), data = df_s2m_t, weights = 1/studyobs) #WLS 1/studyobs 
HighLeverage <- cooks.distance(model_s2m_t_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t_3) > 3
df_s2m_t_3_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_3 <- lm(tprobit ~ sqrt(df), data = df_s2m_t_3_hl, weights = 1/studyobs) #WLS 1/studyobs 
print(coeftest(hlmodel_s2m_t_3, cluster.vcov(hlmodel_s2m_t_3, cbind(df_s2m_t_3_hl$study_id, df_s2m_t_3_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t_4 <- lm(tprobit ~ sqrt(df), data = df_s2m_t, weights = studyquali) #WLS studyquali
HighLeverage <- cooks.distance(model_s2m_t_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t_4) > 3
df_s2m_t_4_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_4 <- lm(tprobit ~ sqrt(df), data = df_s2m_t_4_hl, weights = studyquali) #WLS studyquali
print(coeftest(hlmodel_s2m_t_4, cluster.vcov(hlmodel_s2m_t_4, cbind(df_s2m_t_4_hl$study_id, df_s2m_t_4_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t_5 <- lm(tprobit ~ sqrt(df), data = df_s2m_t, weights = 1/calc_var) #WLS 1/calc_var
HighLeverage <- cooks.distance(model_s2m_t_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t_5) > 3
df_s2m_t_5_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_5 <- lm(tprobit ~ sqrt(df), data = df_s2m_t_5_hl, weights = 1/calc_var) #WLS 1/calc_var
print(coeftest(hlmodel_s2m_t_5, cluster.vcov(hlmodel_s2m_t_5, cbind(df_s2m_t_5_hl$study_id, df_s2m_t_5_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

#Subset B
model_s2m_t2_1 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2)
HighLeverage <- cooks.distance(model_s2m_t2_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t2_1) > 3
df_s2m_t2_1_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t2_1 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2_1_hl)
print(coeftest(hlmodel_s2m_t2_1, cluster.vcov(hlmodel_s2m_t2_1, cbind(df_s2m_t2_1_hl$study_id, df_s2m_t2_1_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t2_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t2_2 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2, weights = sqrt(df)) #WLS sqrt(DF)
HighLeverage <- cooks.distance(model_s2m_t2_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t2_2) > 3
df_s2m_t2_2_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t2_2 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2_2_hl, weights = sqrt(df)) #WLS sqrt(DF)
print(coeftest(hlmodel_s2m_t2_2, cluster.vcov(hlmodel_s2m_t2_2, cbind(df_s2m_t2_2_hl$study_id, df_s2m_t2_2_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t2_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t2_3 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2, weights = 1/studyobs) #WLS 1/studyobs
HighLeverage <- cooks.distance(model_s2m_t2_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t2_3) > 3
df_s2m_t2_3_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t2_3 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2_3_hl, weights = 1/studyobs) #WLS 1/studyobs
print(coeftest(hlmodel_s2m_t2_3, cluster.vcov(hlmodel_s2m_t2_3, cbind(df_s2m_t2_3_hl$study_id, df_s2m_t2_3_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t2_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t2_4 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2, weights = studyquali) #WLS studyquali
HighLeverage <- cooks.distance(model_s2m_t2_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t2_4) > 3
df_s2m_t2_4_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t2_4 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2_4_hl, weights = studyquali) #WLS studyquali
print(coeftest(hlmodel_s2m_t2_4, cluster.vcov(hlmodel_s2m_t2_4, cbind(df_s2m_t2_4_hl$study_id, df_s2m_t2_4_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t2_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m_t2_5 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2, weights = 1/calc_var) #WLS 1/calc_var
HighLeverage <- cooks.distance(model_s2m_t2_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_t2_5) > 3
df_s2m_t2_5_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t2_5 <- lm(t2probit ~ sqrt(df), data = df_s2m_t2_5_hl, weights = 1/calc_var) #WLS 1/calc_var
print(coeftest(hlmodel_s2m_t2_5, cluster.vcov(hlmodel_s2m_t2_5, cbind(df_s2m_t2_5_hl$study_id, df_s2m_t2_5_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t2_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

#Testing
#Set model for analysis
#model_list <- list(model_s2m_t_1, model_s2m_t_2, model_s2m_t_3, model_s2m_t_4, 
#                   model_s2m_t2_1, model_s2m_t2_2, model_s2m_t2_3, model_s2m_t2_4)
#for (model in model_list){
#  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
#}
hlmodel_list <- list(model_s2m_t_1, model_s2m_t_2, model_s2m_t_3, model_s2m_t_4, 
                   model_s2m_t2_1, model_s2m_t2_2, model_s2m_t2_3, model_s2m_t2_4)
for (model in hlmodel_list){
  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
}

distinct(df_s2m_t2_4_hl, study_id)
nrow(df_s2m_t2_4_hl)


model = hlmodel_s2m_t2_4

print(lmtest::bptest(model))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_autocorrelation(model)
check_outliers(model)
check_normality(i)
check_heteroscedasticity(model)
#check_collinearity(model)
#Outliers detected! 1 for WLS2 1519 for A and 944, 1519 for B

#model = model_s2m_t_2
#vcov_both <- cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs))
#coeftest(model, vcov_both) # Clustered Standard error  

#coeftest(model, vcov = vcovHC(model, type = "HC5"))
#vcov_both3 <- cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs), leverage = 3)
#coeftest(model, vcov_both3) #Clustered Standard error with MacKinnon and White (1985) performance improfement
#mclx(model,1, df_s2m_t$study_id, df_s2m_t$studyobs)
#vcov_both <- cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs))
#coeftest(model, vcov_both) # Clustered Standard error

#Clustered Standard error boot strap
#boot_both <- cluster.boot(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs))
#coeftest(model, boot_both)

#Testing 
#lmtest::bptest(model)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
#coeftest(model_s2m_t2_1, vcov = vcovHC(model, type = "HC4"))
#coeftest(model_s2m_t2_2, vcov = vcovHC(model, type = "HC5"))
#coeftest(model, df = Inf, vcov = NeweyWest) #Account for Autocorrelation

##########################
###Testing for problems###
##########################
#1. Non-linearity - Residual Plot
#plot(fitted(model_s2m), residuals(model_s2m), xlab = "Fitted Values", ylab = "Residuals")
#abline(h=0, lty=2)
#lines(smooth.spline(fitted(model_s2m), residuals(model_s2m)))
#2. Correlation of error terms
#3. non-constant variance of error terms
#4. outliers
#5. high-leverage points
#6. Collinearity / multicollinearity

#performance::check_model(model_s2m)
#linearHypothesis(model_s2m, c("dmetal=0", "dsoft=0"))
#car::ncvTest(model_s2m) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test - less robust https://stats.stackexchange.com/questions/193061/what-is-the-difference-between-these-two-breusch-pagan-tests

#########################
###Advanced MRA - Lags###
#########################

#Advanced MRA - S2M
model_s2m2_t_1 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_t)
HighLeverage <- cooks.distance(model_s2m2_t_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t_1) > 3
df_s2m_2_t_1_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m_t_1 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_2_t_1_hl)
print(coeftest(hlmodel_s2m_t_1, cluster.vcov(hlmodel_s2m_t_1, cbind(df_s2m_2_t_1_hl$study_id, df_s2m_2_t_1_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m_t_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t_2 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_t, weights = sqrt(df)) #WLS sqrt(DF)
HighLeverage <- cooks.distance(model_s2m2_t_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t_2) > 3
df_s2m_2_t_2_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t_2 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_2_t_2_hl, weights = sqrt(df)) #WLS sqrt(DF)
print(coeftest(hlmodel_s2m2_t_2, cluster.vcov(hlmodel_s2m2_t_2, cbind(df_s2m_2_t_2_hl$study_id, df_s2m_2_t_2_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t_3 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_t, weights = 1/studyobs) #WLS 1/studyobs
HighLeverage <- cooks.distance(model_s2m2_t_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t_3) > 3
df_s2m_2_t_3_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t_3 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_2_t_3_hl, weights = 1/studyobs) #WLS 1/studyobs
print(coeftest(hlmodel_s2m2_t_3, cluster.vcov(hlmodel_s2m2_t_3, cbind(df_s2m_2_t_3_hl$study_id, df_s2m_2_t_3_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t_4 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_t, weights = studyquali) #WLS studyquali
HighLeverage <- cooks.distance(model_s2m2_t_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t_4) > 3
df_s2m_2_t_4_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t_4 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_2_t_4_hl, weights = studyquali) #WLS studyquali
print(coeftest(hlmodel_s2m2_t_4, cluster.vcov(hlmodel_s2m2_t_4, cbind(df_s2m_2_t_4_hl$study_id, df_s2m_2_t_4_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t_5 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_t, weights = 1/calc_var) #WLS 1/calc_var
HighLeverage <- cooks.distance(model_s2m2_t_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t_5) > 3
df_s2m_2_t_5_hl <- df_s2m_t[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t_5 <- lm(tprobit ~ sqrt(df) + m, data = df_s2m_2_t_5_hl, weights = 1/calc_var) #WLS 1/calc_var
print(coeftest(hlmodel_s2m2_t_5, cluster.vcov(hlmodel_s2m2_t_5, cbind(df_s2m_2_t_5_hl$study_id, df_s2m_2_t_5_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t2_1 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_t2)
HighLeverage <- cooks.distance(model_s2m2_t2_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t2_1) > 3
df_s2m_2_t2_1_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t2_1 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_2_t2_1_hl)
print(coeftest(hlmodel_s2m2_t2_1, cluster.vcov(hlmodel_s2m2_t2_1, cbind(df_s2m_2_t2_1_hl$study_id, df_s2m_2_t2_1_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t2_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t2_2 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_t2, weights = sqrt(df)) #WLS sqrt(DF)
HighLeverage <- cooks.distance(model_s2m2_t2_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t2_2) > 3
df_s2m_2_t2_2_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t2_2 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_2_t2_2_hl, weights = sqrt(df)) #WLS sqrt(DF)
print(coeftest(hlmodel_s2m2_t2_2, cluster.vcov(hlmodel_s2m2_t2_2, cbind(df_s2m_2_t2_2_hl$study_id, df_s2m_2_t2_2_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t2_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t2_3 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_t2, weights = 1/studyobs) #WLS 1/studyobs
HighLeverage <- cooks.distance(model_s2m2_t2_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t2_3) > 3
df_s2m_2_t2_3_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t2_3 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_2_t2_3_hl, weights = 1/studyobs) #WLS 1/studyobs
print(coeftest(hlmodel_s2m2_t2_3, cluster.vcov(hlmodel_s2m2_t2_3, cbind(df_s2m_2_t2_3_hl$study_id, df_s2m_2_t2_3_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t2_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t2_4 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_t2, weights = studyquali) #WLS studyquali
HighLeverage <- cooks.distance(model_s2m2_t2_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t2_4) > 3
df_s2m_2_t2_4_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t2_4 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_2_t2_4_hl, weights = studyquali) #WLS studyquali
print(coeftest(hlmodel_s2m2_t2_4, cluster.vcov(hlmodel_s2m2_t2_4, cbind(df_s2m_2_t2_4_hl$study_id, df_s2m_2_t2_4_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t2_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

model_s2m2_t2_5 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_t2, weights = 1/calc_var) #WLS 1/calc_var
HighLeverage <- cooks.distance(model_s2m2_t2_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m2_t2_5) > 3
df_s2m_2_t2_5_hl <- df_s2m_t2[!HighLeverage & !LargeResiduals,]
hlmodel_s2m2_t2_5 <- lm(t2probit ~ sqrt(df) + m, data = df_s2m_2_t2_5_hl, weights = 1/calc_var) #WLS 1/calc_var
print(coeftest(hlmodel_s2m2_t2_5, cluster.vcov(hlmodel_s2m2_t2_5, cbind(df_s2m_2_t2_5_hl$study_id, df_s2m_2_t2_5_hl$studyobs)))) # Clustered Standard error
print(lmtest::bptest(hlmodel_s2m2_t2_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

distinct(df_s2m_2_t2_4_hl, study_id)
nrow(df_s2m_2_t2_4_hl)


#Testing
#Set model for analysis
#model2_list <- list(model_s2m2_t_1, model_s2m2_t_2, model_s2m2_t_3, model_s2m2_t_4)
#model2_t2list <- list(model_s2m2_t2_1, model_s2m2_t2_2, model_s2m2_t2_3, model_s2m2_t2_4)
#for (model in model2_list){
#  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
#}
#for (model in model2_t2list){
#  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
#}

hlmodel2_list <- list(hlmodel_s2m2_t_1, hlmodel_s2m2_t_2, hlmodel_s2m2_t_3, hlmodel_s2m2_t_4)
hlmodel2_t2list <- list(hlmodel_s2m2_t2_1, hlmodel_s2m2_t2_2, hlmodel_s2m2_t2_3, hlmodel_s2m2_t2_4)

for (model in model2_list){
  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
}
for (model in model2_t2list){
  print(coeftest(model, cluster.vcov(model, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)))) # Clustered Standard error  
}



model = model_s2m2_t_4
#Testing 
print(lmtest::bptest(model))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_autocorrelation(model)
check_outliers(model)
check_normality(i)
check_heteroscedasticity(model)
check_collinearity(model)

#One outlier for model WLS2 A 1519, B 944, 1519
car::outlierTest(model_s2m2_t2_3)

#coeftest(model_s2m, vcov = vcovHC(model_s2m, type = "HC3"))
#mclx(model_s2m,1, df_s2m_t$study_id, df_s2m_t$studyobs)
distinct(df_s2m, study_id)
nrow(df_s2m)
lmtest::bptest(model)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::vif(model_s2m2_t2_5)
check_collinearity(model_s2m2_t2_5)

check_model(model)
model_performance(model)

check_distribution(model)
performance_mse(model)
car::residualPlots(model)

#################################
###Testing for correlationetc.###
#################################
dummy_list <- list("df", "m", "dmetal", "denergy", "dsoft",  "dfstat", "dchi2","dtstat",
                   "dlev", "ddif", "dlin", "dlog",
                   "dvarvec", "dadl","dcontemp", "dsum", "dsingle", "dzvar", "dlineargc", "dnonparagc", "dquantilegc", 
                   "dmultivariategc", "daicplus", "dbicplus", "dpretest", "dcftc", "dfuture", 
                   "daily", "weekly", "monthly", "quarterly", "avgyear", "pubyear", "d2007", "dinfluenced", "dtype", 
                   "dranking", "samps_calc", "dpvalcalc",
                   "dreturn", "dvola", "doi", "dpos", "dvolume")

#Ohne Base
dummy_list <- list("df", "m", "dmetal", "dsoft","dchi2","dtstat",
                   "ddif", "dlog",
                   "dvarvec", "dcontemp", "dsum", "dzvar", "dnonparagc", "dquantilegc", 
                   "dmultivariategc", "daicplus", "dbicplus", "dpretest", "dcftc",  
                   "daily", "monthly", "quarterly", "avgyear", "pubyear", "d2007", "dinfluenced", "dtype", 
                   "dranking", "samps_calc", "dpvalcalc",
                   "dreturn", "dvola", "doi", "dpos", "dvolume")


#dfuture
#excluded_list <- list("denergy", "dlev", "dlin", "dadl", "dsingle", "dlineargc", "dfstat", "weekly")

df_corr <- df_s2m[ , unlist(dummy_list)]
num.cols <- sapply(df_corr, is.numeric)
cor.data <- cor(df_corr[,num.cols])
cor.data
summary(df_corr)

#df_corr <- df_s2m[ , unlist(excluded_list)]
#num.cols <- sapply(df_corr, is.numeric)
#cor.data <- cor(df_corr[,num.cols])
#cor.data
summary(cor.data)

##################################
###Testing for multicollin etc.###
##################################
dummy_list <- list("df", "m", "dmetal", "dsoft","dchi2","dtstat",
                   "ddif", "dlog",
                   "dvarvec", "dcontemp", "dsum", "dzvar", "dnonparagc", "dquantilegc", 
                   "dmultivariategc", "daicplus", "dbicplus", "dpretest", "dcftc",  
                   "daily", "monthly", "quarterly", "avgyear", "pubyear", "d2007", "dinfluenced", "dtype", 
                   "dranking", "samps_calc", "dpvalcalc",
                   "dreturn", "dvola", "doi", "dpos", "dvolume")
table(unlist(df_coded$dmultivariategc))
cor.data
#Setup the model
table(unlist(df_coded$dmultivariategc))
model_s2m_6_t_1 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t)
check_collinearity(model_s2m_6_t_1)


model_s2m_6_t2_1 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2)

check_collinearity(model_s2m_6_t2_1)


###########################################################################################################################################



###################################
###6 multiple MRA model - 240420 - reduced because of collinearity: contemp, quarterly, dmultivariategc, dquantilegc, dinfluenced, dbicplus, dpretest###
###################################
model_s2m_6_t_1 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t)
HighLeverage <- cooks.distance(model_s2m_6_t_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_1) > 3
df_s2m_m6t_1 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_1 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_m6t_1)
print(coeftest(fmodel_s2m_6_t_1, cluster.vcov(fmodel_s2m_6_t_1, cbind(df_s2m_m6t_1$study_id, df_s2m_m6t_1$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t_1, cluster.vcov(fmodel_s2m_6_t_1, cbind(df_s2m_m6t_1$study_id, df_s2m_m6t_1$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t_1)

model_s2m_6_t_2 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t, weights = sqrt(df)) #WLS1 sqrt(DF)) 
HighLeverage <- cooks.distance(model_s2m_6_t_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_2) > 3
df_s2m_m6t_2 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_2 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_m6t_2, weights = sqrt(df)) #WLS1 sqrt(DF)) 
print(coeftest(fmodel_s2m_6_t_2, cluster.vcov(fmodel_s2m_6_t_2, cbind(df_s2m_m6t_2$study_id, df_s2m_m6t_2$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t_2, cluster.vcov(fmodel_s2m_6_t_2, cbind(df_s2m_m6t_2$study_id, df_s2m_m6t_2$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t_2)

model_s2m_6_t_3 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t, weights = 1/studyobs) #WLS2 1/studyobs
HighLeverage <- cooks.distance(model_s2m_6_t_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_3) > 3
df_s2m_m6t_3 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_3 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_m6t_3, weights = 1/studyobs) #WLS2 1/studyobs
print(coeftest(fmodel_s2m_6_t_3, cluster.vcov(fmodel_s2m_6_t_3, cbind(df_s2m_m6t_3$study_id, df_s2m_m6t_3$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t_3, cluster.vcov(fmodel_s2m_6_t_3, cbind(df_s2m_m6t_3$study_id, df_s2m_m6t_3$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t_3)

model_s2m_6_t_4 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t, weights = studyquali) #WLS3 studyquali
HighLeverage <- cooks.distance(model_s2m_6_t_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_4) > 3
df_s2m_m6t_4 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_4 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_m6t_4, weights = studyquali) #WLS3 studyquali
print(coeftest(fmodel_s2m_6_t_4, cluster.vcov(fmodel_s2m_6_t_4, cbind(df_s2m_m6t_4$study_id, df_s2m_m6t_4$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t_4, cluster.vcov(fmodel_s2m_6_t_4, cbind(df_s2m_m6t_4$study_id, df_s2m_m6t_4$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t_4)

model_s2m_6_t_5 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                        dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                        dvola + doi + dvolume, data = df_s2m_t, weights = 1/calc_var) #WLS4 1/variance
HighLeverage <- cooks.distance(model_s2m_6_t_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_5) > 3
df_s2m_m6t_5 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_5 <- lm(tprobit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_m6t_5, weights = 1/calc_var) #WLS4 1/variance
print(coeftest(fmodel_s2m_6_t_5, cluster.vcov(fmodel_s2m_6_t_5, cbind(df_s2m_m6t_5$study_id, df_s2m_m6t_5$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t_5, cluster.vcov(fmodel_s2m_6_t_5, cbind(df_s2m_m6t_5$study_id, df_s2m_m6t_5$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t_5)
##############
###Model t2###
##############
model_s2m_6_t2_1 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2)
HighLeverage <- cooks.distance(model_s2m_6_t2_1) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_1) > 3
df_s2m_m6t2_1 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_1 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                          dvola + doi + dvolume, data = df_s2m_m6t2_1)
print(coeftest(fmodel_s2m_6_t2_1, cluster.vcov(fmodel_s2m_6_t2_1, cbind(df_s2m_m6t2_1$study_id, df_s2m_m6t2_1$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t2_1, cluster.vcov(fmodel_s2m_6_t2_1, cbind(df_s2m_m6t2_1$study_id, df_s2m_m6t2_1$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t2_1))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t2_1)

model_s2m_6_t2_2 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2, weights = sqrt(df)) #WLS1 sqrt(DF)) 
HighLeverage <- cooks.distance(model_s2m_6_t2_2) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_2) > 3
df_s2m_m6t2_2 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_2 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                          dvola + doi + dvolume, data = df_s2m_m6t2_2, weights = sqrt(df)) #WLS1 sqrt(DF)) 
print(coeftest(fmodel_s2m_6_t2_2, cluster.vcov(fmodel_s2m_6_t2_2, cbind(df_s2m_m6t2_2$study_id, df_s2m_m6t2_2$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t2_2, cluster.vcov(fmodel_s2m_6_t2_2, cbind(df_s2m_m6t2_2$study_id, df_s2m_m6t2_2$studyobs)), leverage = 3)) # Experimenal clustered Standard error  
print(lmtest::bptest(fmodel_s2m_6_t2_2))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t2_2)

model_s2m_6_t2_3 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2, weights = 1/studyobs) #WLS2 1/studyobs
HighLeverage <- cooks.distance(model_s2m_6_t2_3) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_3) > 3
df_s2m_m6t2_3 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_3 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                          dvola + doi + dvolume, data = df_s2m_m6t2_3, weights = 1/studyobs) #WLS2 1/studyobs
print(coeftest(fmodel_s2m_6_t2_3, cluster.vcov(fmodel_s2m_6_t2_3, cbind(df_s2m_m6t2_3$study_id, df_s2m_m6t2_3$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t2_3, cluster.vcov(fmodel_s2m_6_t2_3, cbind(df_s2m_m6t2_3$study_id, df_s2m_m6t2_3$studyobs)), leverage = 3)) # Experimenal clustered Standard error 
print(lmtest::bptest(fmodel_s2m_6_t2_3))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t2_3)

model_s2m_6_t2_4 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2, weights = studyquali) #WLS3 studyquali
HighLeverage <- cooks.distance(model_s2m_6_t2_4) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_4) > 3
df_s2m_m6t2_4 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_4 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                          dvola + doi + dvolume, data = df_s2m_m6t2_4, weights = studyquali) #WLS3 studyquali
print(coeftest(fmodel_s2m_6_t2_4, cluster.vcov(fmodel_s2m_6_t2_4, cbind(df_s2m_m6t2_4$study_id, df_s2m_m6t2_4$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t2_4, cluster.vcov(fmodel_s2m_6_t2_4, cbind(df_s2m_m6t2_4$study_id, df_s2m_m6t2_4$studyobs)), leverage = 3)) # Experimenal clustered Standard error 
print(lmtest::bptest(fmodel_s2m_6_t2_4))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t2_4)

model_s2m_6_t2_5 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                         dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                         dvola + doi + dvolume, data = df_s2m_t2, weights = 1/calc_var) #WLS4 1/variance
HighLeverage <- cooks.distance(model_s2m_6_t2_5) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_5) > 3
df_s2m_m6t2_5 <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_5 <- lm(t2probit ~ sqrt(df) + m + commodity_name + dchi2 + dtstat + ddif + dlog + dsum + dvarvec + dzvar + 
                          dnonparagc + dmultivariategc + daicplus + dcftc + monthly + d2007 + dinfluenced + dranking + 
                          dvola + doi + dvolume, data = df_s2m_m6t2_5, weights = 1/calc_var) #WLS4 1/variance
print(coeftest(fmodel_s2m_6_t2_5, cluster.vcov(fmodel_s2m_6_t2_5, cbind(df_s2m_m6t2_5$study_id, df_s2m_m6t2_5$studyobs)))) # Clustered Standard error
print(coeftest(fmodel_s2m_6_t2_5, cluster.vcov(fmodel_s2m_6_t2_5, cbind(df_s2m_m6t2_5$study_id, df_s2m_m6t2_5$studyobs)), leverage = 3)) # Experimenal clustered Standard error 
print(lmtest::bptest(fmodel_s2m_6_t2_5))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
check_collinearity(fmodel_s2m_6_t2_5)

###########
###Tests###
###########
df_test <- df_s2m_m6t_1
distinct(df_test, study_id)
nrow(df_test)

###########################
###Experimental approach - 290420###
###########################
t1_list <- list(model_s2m_6_t_1, model_s2m_6_t_2, model_s2m_6_t_3, model_s2m_6_t_4, model_s2m_6_t_5)
t2_list  <- list(model_s2m_6_t2_1, model_s2m_6_t2_2, model_s2m_6_t2_3, model_s2m_6_t2_4, model_s2m_6_t2_5)


for (i in t1_list){
  print(coeftest(i, cluster.vcov(i, cbind(df_s2m_t$study_id, df_s2m_t$studyobs)), leverage = 3)) # Experimenal clustered Standard error 
  print(lmtest::bptest(i))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
}
for (i in t2_list){
  print(coeftest(i, cluster.vcov(i, cbind(df_s2m_t2$study_id, df_s2m_t2$studyobs)), leverage = 3)) # Experimenal clustered Standard error 
  print(lmtest::bptest(i))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
}

df_test <- df_s2m_t2
distinct(df_test, study_id)
nrow(df_test)
 
#########################
###Reduced MRA model 6###
#########################
#Subset A
model_s2m_6_t_3_reduced <- lm(tprobit ~ dmetal + dlog + dsum
                                , data = df_s2m_t, weights = 1/studyobs) #WLS2 1/studyobs
HighLeverage <- cooks.distance(model_s2m_6_t_3_reduced) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t_3_reduced) > 3
df_s2m_m6t_3_reduced <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t_3_reduced <- lm(tprobit ~ dmetal + dlog + dsum 
                                 , data = df_s2m_m6t_3_reduced, weights = 1/studyobs) #WLS2 1/studyobs
print(coeftest(fmodel_s2m_6_t_3_reduced, cluster.vcov(fmodel_s2m_6_t_3_reduced, cbind(df_s2m_m6t_3_reduced$study_id, df_s2m_m6t_3_reduced$studyobs)))) # Clustered Standard error
print(lmtest::bptest(fmodel_s2m_6_t_3_reduced))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

#Subset B
model_s2m_6_t2_3_reduced <- lm(t2probit ~ m + dmetal + ddif + dlog +   
                                 dmultivariategc    
                                 , data = df_s2m_t2, weights = 1/studyobs) #WLS2 1/studyobs
HighLeverage <- cooks.distance(model_s2m_6_t2_3_reduced) > (4/nrow(df_s2m))
LargeResiduals <- rstudent(model_s2m_6_t2_3_reduced) > 3
df_s2m_m6t2_3_reduced <- df_s2m[!HighLeverage & !LargeResiduals,]
fmodel_s2m_6_t2_3_reduced <- lm(t2probit ~ m + dmetal + ddif + dlog + 
                                  dmultivariategc    
                                  , data = df_s2m_m6t2_3_reduced, weights = 1/studyobs) #WLS2 1/studyobs
print(coeftest(fmodel_s2m_6_t2_3_reduced, cluster.vcov(fmodel_s2m_6_t2_3_reduced, cbind(df_s2m_m6t2_3_reduced$study_id, df_s2m_m6t2_3_reduced$studyobs)))) # Clustered Standard error
print(lmtest::bptest(fmodel_s2m_6_t2_3_reduced))  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test

##############################################################################################################################################

##################################################
###Predict Best practice model - MRA 6 - 240420###
##################################################

#Full B subsample, vola
df_predict_1 <- data.frame(df = 850, m = 3, commodity_name = "gsoft", dchi2 = 0, dtstat = 0, ddif = 1, dlog = 0, 
                           dsum = 0, dvarvec = 1, dzvar = 0.08077, dnonparagc = 0, dmultivariategc = 0,  daicplus = 0, 
                           dcftc = 0.54, monthly = 0, dinfluenced = 0.53, 
                           dranking = 0, 
                           d2007 = 0,
                           dvola = 0, 
                           doi = 0, 
                           dvolume = 0)
df_predict_2 <- data.frame(df = 850, m = 3, commodity_name = "genergy", dchi2 = 0, dtstat = 0, ddif = 1, dlog = 0, 
                           dsum = 0, dvarvec = 1, dzvar = 0.08077, dnonparagc = 0, dmultivariategc = 0,  daicplus = 0, 
                           dcftc = 0.54, monthly = 0, dinfluenced = 0.53, 
                           dranking = 0, 
                           d2007 = 0,
                           dvola = 0, 
                           doi = 0, 
                           dvolume = 0)
df_predict_3 <- data.frame(df = 850, m = 3, commodity_name = "gmetal", dchi2 = 0, dtstat = 0, ddif = 1, dlog = 0, 
                           dsum = 0, dvarvec = 1, dzvar = 0.08077, dnonparagc = 0, dmultivariategc = 0,  daicplus = 0, 
                           dcftc = 0.54, monthly = 0, dinfluenced = 0.53, 
                           dranking = 0, 
                           d2007 = 0,
                           dvola = 0, 
                           doi = 0, 
                           dvolume = 0)

predict_list <- list(df_predict_1, df_predict_2, df_predict_3)

for (predict in predict_list){
  print(pnorm(-predict(fmodel_s2m_6_t2_3, predict)))
}


###############################
###Install and load packages###
###############################
install.packages("dummies")
install.packages('plotly')
install.packages('ggthemes')
install.packages('dplyr')
install.packages('plotly')
install.packages('yaml')
install.packages('lmtest')

#MetaAnalysePackages
#library(compute.es)# TO COMPUTE EFFECT SIZES
#library(MAd) # META-ANALYSIS PACKAGE
#install.packages("metafor")
#library(metafor) # META-ANALYSIS PACKAGE
load_packages <- function(x){
  update.packages()
  #Read full Coding Excel file Packages
  library(readxl)
  #Data cleaning & analysing
  library(dplyr)
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
}
load_packages()

varianz <- function(x) {n=length(x) ; var(x) * (n-1) / n}
stddev <- function(x) {n=length(x) ; sqrt(var(x) * (n-1) / n)}
xlsxreader <- function(path, sheet){
  read_excel(path, sheet = sheet, col_types = c("numeric", "numeric", "numeric",
                                                "text", "text", "text", "text", "text",
                                                "text", "text", "text", "text", "text", "numeric",
                                                "text", "text", "text", "numeric", "numeric", "numeric", 
                                                "numeric",
                                                "numeric", "numeric", "text", "text",
                                                "text", "text", "numeric", "numeric", "text",
                                                "text", "text", "text", "date",
                                                "date", "text", "numeric", "text",
                                                "numeric", "text", "numeric", "numeric",
                                                "numeric", "text", "text", "numeric",
                                                "numeric", "numeric", "numeric",
                                                "numeric", "numeric", "numeric",
                                                "numeric", "numeric", "numeric",
                                                "text", "text"))
}

###############################################
###Load Excel data, Setup & Adjust Dataframe###
###############################################
#load_df <- function(){
  path <- "E:/02 temp/R Code/Coding_MH_290220.xlsx"
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
                                       "numeric", "numeric", "date", "date", "text"))
  
  df_coded <- merge(df_codefile, df_paper, by=1)
  
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
  df_coded["omitted"] <- NULL
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
                   "tindex")
  
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
  other <- list("fund rolling", "posetf", "posetfnv", "cposetf")
  
  
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
  
  #m Lag normalisation - on daily base - ohne HFT
  #df_coded$tm <- ifelse(df_coded$period == "weekly", df_coded$m*5, df_coded$m)
  #df_coded$tm <- ifelse(df_coded$period == "monthly", df_coded$m*20, df_coded$m)
  #df_coded$tm <- ifelse(df_coded$period == "quarterly", df_coded$m*20*3, df_coded$m)
  
  #m Lag normalisation - on quarterly base
  df_coded$tm <- ifelse(df_coded$period == "5 min", df_coded$m/6/2/24/5/4/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "30 min", df_coded$m/2/24/5/4/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "60 min", df_coded$m/24/5/4/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "daily", df_coded$m/5/4/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "weekly", df_coded$m/4/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "monthly", df_coded$m/3, df_coded$m)
  df_coded$tm <- ifelse(df_coded$period == "quarterly", df_coded$m/1, df_coded$m)
  
  #n Lag normalisation - on daily base - ohne HFT
  #df_coded$tn <- ifelse(df_coded$period == "weekly", df_coded$n*5, df_coded$m)
  #df_coded$tn <- ifelse(df_coded$period == "monthly", df_coded$n*20, df_coded$m)
  #df_coded$tn <- ifelse(df_coded$period == "quarterly", df_coded$n*20*3, df_coded$m)
  
  #m Lag normalisation - on quarterly base
  df_coded$tn <- ifelse(df_coded$period == "5 min", df_coded$n/6/2/24/5/4/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "30 min", df_coded$n/2/24/5/4/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "60 min", df_coded$n/24/5/4/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "daily", df_coded$n/5/4/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "weekly", df_coded$n/4/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "monthly", df_coded$n/3, df_coded$n)
  df_coded$tn <- ifelse(df_coded$period == "quarterly", df_coded$n/1, df_coded$n)
  

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
  varvec_list <- list("var", "vec", "sur", "vecm", "ols") ###MUSS NOCHMAL ANGEPASST WERDEN! OLS regression fällt hier raus?###
  df_coded$dvarvec <- ifelse(df_coded$system %in% varvec_list, 1, 0)
  adl_list <- list("adl", "ardl") ###MUSS NOCHMAL ANGEPASST WERDEN!###
  df_coded$dadl <- ifelse(df_coded$system %in% adl_list, 1, 0)
  df_coded$dzvar <- ifelse(df_coded$z_var == "n", 0, 1)
  lineargc_list <- list("standard gc", "ty gc", "instantaneous gc") ###MUSS NOCHMAL ANGEPASST WERDEN!###
  nonparagc_list <- list("dp gc") ###MUSS NOCHMAL ANGEPASST WERDEN!###
  df_coded$dlineargc <- ifelse(df_coded$func_typ %in% lineargc_list, 1, 0)
  df_coded$dnonparagc <- ifelse(df_coded$func_typ %in% nonparagc_list, 1, 0)
  df_coded$daic <- ifelse(df_coded$ic == "aic", 1, 0)
  df_coded$daic <- ifelse(is.na(df_coded$ic), 0, df_coded$daic)
  df_coded$dbic <- ifelse(df_coded$ic == "bic", 1, 0)
  df_coded$dbic <- ifelse(is.na(df_coded$ic), 0, df_coded$dbic)
  aicplus <- list("aic", "aic, bic", "aic, bic, hq", "aic, fpe", "aic, fpe, hq, lr", "aic, hq, bic",
                  "aic, hq, sic", "aic, sic", "modified lr test, final prediction error, aic, bic, hq",
                  "sic, aic")
  bicplus <- list("bic", "aic, bic", "aic, bic, hq", "aic, hq, bic", "aic, hq, sic", "aic, sic", 
                  "modified lr test, final prediction error, aic, bic, hq", "ng-perron, sic", "sic", "sic, aic")
  df_coded$daicplus <- ifelse(df_coded$ic %in% aicplus, 1, 0)
  df_coded$daicplus <- ifelse(is.na(df_coded$ic), 0, df_coded$daicplus)
  df_coded$dbicplus <- ifelse(df_coded$ic %in% bicplus, 1, 0)
  df_coded$dbicplus <- ifelse(is.na(df_coded$ic), 0, df_coded$dbicplus)
  adf <- list("adf", "adf-gls, zivot and andrews,  kejriwal and perron", "adf-gls, zivot and andrews, kejriwal and perron",
              "adf, ardl", "adf, chow test", "adf, engel-granger test", "adf, engle and granger test, johansen test", 
              "adf, kpss", "adf, kpss, lm, engle granger test, johansen", "adf, lm", "adf, newey-west correction", "df, ng-perron",
              "adf, pp", "adf, pp, ers", "adf, pp, lm", "adf, pp, np, kpss", "adf, zivot–andrews tests, clement–montañes–reyes tests",
              "adf, zivot and andrews", "johansen test, adf")
  df_coded$dadf <- ifelse(df_coded$pretest %in% adf, 1, 0)
  df_coded$dcftc <- ifelse(df_coded$x_data_source == "gcftc" | df_coded$y_data_source == "gcftc", 1, 0)
  df_coded$dcftc <- ifelse(is.na(df_coded$x_data_source) | is.na(df_coded$y_data_source), 0, df_coded$dcftc)
  df_coded$dbic <- ifelse(is.na(df_coded$ic), 0, df_coded$dbic)
  df_coded$dfuture <- ifelse(df_coded$x_sf == "f" | df_coded$y_sf == "f", 1, 0)
  df_coded$daily <- ifelse(df_coded$period == "daily", 1, 0)
  df_coded$weekly <- ifelse(df_coded$period == "weekly", 1, 0)
  df_coded$monthly <- ifelse(df_coded$period == "monthly", 1, 0)
  df_coded$quarterly <- ifelse(df_coded$period == "quarterly", 1, 0)
  df_coded$avgyear <- (year(df_coded$startyear) + year(df_coded$endyear))/2
  #df_coded$pubyear <- year(as.Date(df_coded$pubyear))
  df_coded$dinfluenced <- ifelse(is.na(df_coded$influenced), 0, 1)
  df_coded$dtype <- ifelse(df_coded$type == "article", 1, 0)
  df_coded$sjr2018 <- ifelse(is.na(df_coded$sjr2018), 0, df_coded$sjr2018)
  df_coded$ajg2018 <- ifelse(is.na(df_coded$ajg2018), 0, df_coded$ajg2018)
  df_coded$googlecits <- ifelse(is.na(df_coded$googlecits), 0, df_coded$googlecits)
  df_coded$repec <- ifelse(is.na(df_coded$repec), 0, df_coded$repec)
  
  df_coded$ranking <- (df_coded$sjr2018/sum(df_coded$sjr2018) + df_coded$ajg2018/sum(df_coded$ajg2018) + df_coded$googlecits/sum(df_coded$googlecits)
                       + df_coded$repec/sum(df_coded$repec))/4
  df_coded$dranking <- ifelse(df_coded$ranking >= quantile(df_coded$ranking, 0.75), 1, 0)
  #samps_calc
  studyid_calc_pval <- list(7, 18, 26, 34, 38, 47, 49) #Liste von Studien IDs von in Excel kalkulierten Daten
  df_coded$dpvalcalc <- ifelse(df_coded$study_id %in% studyid_calc_pval, 1, 0)
  
  
  #studyid_pval_0 <- list(3,6,7,9,10,11,13,14,15,16,17,19,20,21,22,23,24,37,45,46,48,49,50,52,53,54,56,58,59,66,69,70)
  
 
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
  df_coded$df <- df_coded$samps-(df_coded$m+df_coded$n)     #Nicht normierte lags
  
  #tdf Model - Normed lags
  df_coded$tdf <- df_coded$samps-(df_coded$tm+df_coded$tn)  #Normierte lags
  
  #Exclude high frequency data
  #df_coded <- filter(df_coded, period != "5 min" & period != "30 min" & period !="60 min")

  
##########################
###Clean Dataset of NAs###
##########################

data_coded_na <- df_coded[ , c("samps", "p_val", "m", "n")]   #Exclude NAs for df, probit, m, n
df_all <- df_coded[complete.cases(data_coded_na), ] # Omit NAs by columns
df_all <- filter(df_all, period != "5 min" & period != "30 min" & period !="60 min") #Exclude high frequency data


##################################
###Count observations per study###
##################################
df_all$studyobs <- NA
for(i in 1:length(sheetnames)){
  temp = dim(subset(df_all, study_id == i))[1]
  df_all$studyobs <- ifelse(df_all$study_id == i, temp, df_all$studyobs)
}


#}
#load_df()



############################
###Descriptive Statistics###
############################

###Count Num of obs per study###

count(df_all)
table(unlist(df_all$study_id))
t(distinct(df_all, study_id, studyobs)) #Check if formula is right

###Count x and y specification###

table(unlist(df_all$x))
table(unlist(df_all$y))

###Barplots for descriptive###

dfsum <- df_all %>% group_by(x) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=x)) + 
  geom_bar(stat="identity") + labs(fill="X Variable")

dfsum <- df_all %>% group_by(y) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=y)) + 
  geom_bar(stat="identity") + labs(fill="Y Variable")

dfsum <- df_all %>% group_by(commodity_name) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=commodity_name)) + 
  geom_bar(stat="identity") + labs(fill="Commodity")

dfsum <- df_all %>% group_by(country_name) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=country_name)) + 
  geom_bar(stat="identity") + labs(fill="Country")

dfsum <- df_all %>% group_by(func_typ) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=func_typ)) + 
  geom_bar(stat="identity") + labs(fill="Function Typ")

dfsum <- df_all %>% group_by(func_form) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=func_form)) + 
  geom_bar(stat="identity") + labs(fill="Function Form")

dfsum <- df_all %>% group_by(type) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=type)) + 
  geom_bar(stat="identity") + labs(fill="Paper Type")

dfsum <- df_all %>% group_by(pubyear) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=pubyear)) + 
  geom_bar(stat="identity") + labs(fill="Publication year")

dfsum <- df_all %>% group_by(googlecits) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=googlecits)) + 
  geom_bar(stat="identity") + labs(fill="Google Citations")

dfsum <- df_all %>% group_by(sjr2018) %>% tally()
ggplot(dfsum, aes(x = 1, y = n, fill=sjr2018)) + 
  geom_bar(stat="identity") + labs(fill="SJR 2018")

###############################
###Mean & Standard Deviation###
###############################

dummy_list <- list("dmetal", "denergy", "dsoft", "dfinancial", "df", "m", "dvarvec", "dadl", "dzvar", "dlineargc",
                   "dnonparagc", "daic", "dbic", "daicplus", "dbicplus", "dadf", "dcftc", "dfuture", "daily", "weekly", "monthly",
                   "quarterly", "avgyear", "pubyear", "dinfluenced", "dtype", "dranking", "samps_calc", "dpvalcalc")


for (i in dummy_list){
  print(round(apply(df_all[i], 2, mean), 3)) 
  print(round(apply(df_all[i], 2, stddev), 3))
}

##########################
###Journal quality test###
##########################

model_journalquality <- lm(sqrt(df) ~ ranking, data = df_all) #OLS
model_journalquality <- lm(sqrt(tdf) ~ ranking, data = df_all) 

summary(model_journalquality)


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
data_subset_all_t <- df_all[ , c("tdf", "tprobit")] 
df_all_t <- df_all[complete.cases(data_subset_all_t), ] # Omit NAs by columns
data_subset_all_t2 <- df_all[ , c("tdf", "t2probit")] 
df_all_t2 <- df_all[complete.cases(data_subset_all_t2), ] # Omit NAs by columns

###S2M - Setup Subset
df_s2m <- filter(df_all, x_sm == "spec" & y_sm == "market")

#S2M -Exclude NA values
data_subset_s2m_norm <- df_s2m[ , c("df", "probit")] 
df_s2m_norm <- df_s2m[complete.cases(data_subset_s2m_norm), ] # Omit NAs by columns
data_subset_s2m_t <- df_s2m[ , c("tdf", "tprobit")] 
df_s2m_t <- df_s2m[complete.cases(data_subset_s2m_t), ] # Omit NAs by columns
data_subset_s2m_t2 <- df_s2m[ , c("tdf", "t2probit")] 
df_s2m_t2 <- df_s2m[complete.cases(data_subset_s2m_t2), ] # Omit NAs by columns

###M2S - Setup Subset
df_m2s <- filter(df_all, x_sm == "market" & y_sm == "spec")

#M2S -Exclude NA values
data_subset_m2s_norm <- df_m2s[ , c("df", "probit")] 
df_m2s_norm <- df_m2s[complete.cases(data_subset_m2s_norm), ] # Omit NAs by columns
data_subset_m2s_t <- df_m2s[ , c("tdf", "tprobit")] 
df_m2s_t <- df_m2s[complete.cases(data_subset_m2s_t), ] # Omit NAs by columns
data_subset_m2s_t2 <- df_m2s[ , c("tdf", "t2probit")] 
df_m2s_t2 <- df_m2s[complete.cases(data_subset_m2s_t2), ] # Omit NAs by columns

###H2M - Setup Subset
df_h2m <- filter(df_all, x_sm == "hedge" & y_sm == "market")

#H2M -Exclude NA values
data_subset_h2m_norm <- df_h2m[ , c("df", "probit")] 
df_h2m_norm <- df_h2m[complete.cases(data_subset_h2m_norm), ] # Omit NAs by columns
data_subset_h2m_t <- df_h2m[ , c("tdf", "tprobit")] 
df_h2m_t <- df_h2m[complete.cases(data_subset_h2m_t), ] # Omit NAs by columns
data_subset_h2m_t2 <- df_h2m[ , c("tdf", "t2probit")] 
df_h2m_t2 <- df_h2m[complete.cases(data_subset_h2m_t2), ] # Omit NAs by columns

###M2H - Setup Subset
df_m2h <- filter(df_all, x_sm == "market" & y_sm == "hedge")

#M2S -Exclude NA values
data_subset_m2h_norm <- df_m2h[ , c("df", "probit")] 
df_m2h_norm <- df_m2h[complete.cases(data_subset_m2h_norm), ] # Omit NAs by columns
data_subset_m2h_t <- df_m2h[ , c("tdf", "tprobit")] 
df_m2h_t <- df_m2h[complete.cases(data_subset_m2h_t), ] # Omit NAs by columns
data_subset_m2h_t2 <- df_m2h[ , c("tdf", "t2probit")] 
df_m2h_t2 <- df_m2h[complete.cases(data_subset_m2h_t2), ] # Omit NAs by columns


###Testing for Genuine effects

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

##S2M - Scatterplot probit vs sqrt(DF) - Für Spec2market (Spekulation x beeinflusst Market y)
pl4 <- ggplot(data=df_s2m_norm, aes(y=tprobit, x=sqrt(df)))
print(ggplotly(pl4 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl5 <- ggplot(data=df_s2m_t, aes(y=tprobit, x=sqrt(tdf)))
print(ggplotly(pl5 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl6 <- ggplot(data=df_s2m_t2, aes(y=t2probit, x=sqrt(tdf)))
print(ggplotly(pl6 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))

###M2S - Scatterplot probit vs sqrt(DF) - Für Market2spec (Market x beeinflusst Spekulation y)
pl7 <- ggplot(data=df_m2s_norm, aes(y=probit, x=sqrt(df)))
print(ggplotly(pl7 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl8 <- ggplot(data=df_m2s_t, aes(y=tprobit, x=sqrt(tdf)))
print(ggplotly(pl8 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl9 <- ggplot(data=df_m2s_t2, aes(y=t2probit, x=sqrt(tdf)))
print(ggplotly(pl9 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))

###M2S - Scatterplot probit vs sqrt(DF) - Für Market2spec (Market x beeinflusst Spekulation y)
pl7 <- ggplot(data=df_m2s_norm, aes(y=probit, x=sqrt(df)))
print(ggplotly(pl7 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl8 <- ggplot(data=df_m2s_t, aes(y=tprobit, x=sqrt(tdf)))
print(ggplotly(pl8 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))
pl9 <- ggplot(data=df_m2s_t2, aes(y=t2probit, x=sqrt(tdf)))
print(ggplotly(pl9 + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + geom_hline(yintercept=1.65, color="red", linetype = 2)))

#Batch process
df_list <- list(df_all_norm, df_all_t, df_all_t2, df_s2m_norm, df_s2m_t, df_s2m_t2, 
                df_m2s_norm, df_m2s_t, df_m2s_t2)

counter = 1
for (i in df_list){
  ggplot(data=i, aes(y=probit, x=sqrt(df))) + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + 
    geom_hline(yintercept=1.65, color="red", linetype = 2)
  ggsave(paste("scatter_", counter,"_", today(), ".png"))
  counter = counter+1
}

#Orca not available ate the University augsburg
#for (i in pl_list){
#  ggplotly(data=i, aes(y=probit, x=sqrt(df))) + geom_point(aes(color=study_id)) + geom_smooth(method=lm) + 
#    geom_hline(yintercept=1.65, color="red", linetype = 2)
#    ggsave(paste("scatter_", as.string(i), "_", today(), ".png"))
#}

###Calculate distribution values
###Barplot StdN distribution & frequenze vs probit
##Barplot probit vs distribution - Für All
pl1 <- ggplot(data=df_all_norm, aes(x=probit))
print(ggplotly(pl1 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl2 <- ggplot(data=df_all_t, aes(x=tprobit))
print(ggplotly(pl2 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl3 <- ggplot(data=df_all_t2, aes(x=t2probit))
print(ggplotly(pl3 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))

##Barplot probit vs distribution - Für Spec2market (Spekulation x beeinflusst Market y)
pl4 <- ggplot(data=df_s2m_norm, aes(x=probit))
print(ggplotly(pl4 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl5 <- ggplot(data=df_s2m_t, aes(x=tprobit))
print(ggplotly(pl5 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl6 <- ggplot(data=df_s2m_t2, aes(x=t2probit))
print(ggplotly(pl6 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))

##Barplot probit vs distribution - Für Market2spec (Market x beeinflusst Spekulation y)
pl7 <- ggplot(data=df_m2s_norm, aes(x=probit))
print(ggplotly(pl7 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl8 <- ggplot(data=df_m2s_t, aes(x=tprobit))
print(ggplotly(pl8 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))
pl9 <- ggplot(data=df_m2s_t2, aes(x=t2probit))
print(ggplotly(pl9 + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))

#print(ggplotly(pl + geom_bar() + stat_function(fun = dnorm)))
#print(ggplotly(pl + geom_histogram(aes(y=..density..)) + geom_density(color='red')))
#print(ggplotly(pl + geom_histogram(aes(y=..density..)) + geom_density(aes(y=0.045*..density..), color='red')))
#print(ggplotly(pl + geom_histogram(aes(y=..density..)) + stat_function(fun = dnorm, color='red')))


#str(df_coded)
#any(is.na(df_all$df))
#any(is.na(df_all$probit))
#any(is.infinite(df_all$probit))
#distinct(select(filter(df_coded, is.infinite(probit)), study_id, data_id, probit), probit, .keep_all = TRUE)
#distinct(select(filter(df_coded, p_val>=1), study_id, data_id, p_val), P_val, .keep_all = TRUE)

###################################
###Basic MRA model / FAT-PET-MRA###
###################################
#Basic MRA - All
#model_all <- lm(probit ~ sqrt(df), data = df_all_norm) #OLS
#model_all <- lm(probit ~ sqrt(df), data = df_all_norm, weights = sqrt(df)) #WLS sqrt(DF)
#model_all <- lm(probit ~ sqrt(df), data = df_all_norm, weights = 1/studyobs) #WLS 1/studyobs

model_all <- rlm(tprobit ~ sqrt(tdf), data = df_all_t)
model_all <- rlm(tprobit ~ sqrt(tdf), data = df_all_t, weights = sqrt(df)) #WLS sqrt(DF)
model_all <- rlm(tprobit ~ sqrt(tdf), data = df_all_t, weights = 1/studyobs) #WLS 1/studyobs

model_all <- rlm(t2probit ~ sqrt(tdf), data = df_all_t2)
model_all <- rlm(t2probit ~ sqrt(tdf), data = df_all_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_all <- rlm(t2probit ~ sqrt(tdf), data = df_all_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_all)
confint(model_all)
lmtest::bptest(model_all)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_all) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#Basic MRA - S2M
model_s2m <- lm(tprobit ~ sqrt(tdf), data = df_s2m_t)
model_s2m <- lm(tprobit ~ sqrt(tdf), data = df_s2m_t, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(tprobit ~ sqrt(tdf), data = df_s2m_t, weights = 1/studyobs) #WLS 1/studyobs

model_s2m <- lm(t2probit ~ sqrt(tdf), data = df_s2m_t2)
model_s2m <- lm(t2probit ~ sqrt(tdf), data = df_s2m_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(t2probit ~ sqrt(tdf), data = df_s2m_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_s2m)
distinct(df_s2m, study_id)
nrow(df_s2m)
lmtest::bptest(model_s2m)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_s2m) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#Basic MRA - M2S
model_m2s <- lm(tprobit ~ sqrt(tdf), data = df_m2s_t)
model_m2s <- lm(tprobit ~ sqrt(tdf), data = df_m2s_t, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(tprobit ~ sqrt(tdf), data = df_m2s_t, weights = 1/studyobs) #WLS 1/studyobs

model_m2s <- lm(t2probit ~ sqrt(tdf), data = df_m2s_t2)
model_m2s <- lm(t2probit ~ sqrt(tdf), data = df_m2s_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(t2probit ~ sqrt(tdf), data = df_m2s_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_m2s)
distinct(df_m2s, study_id)
nrow(df_m2s)
lmtest::bptest(model_m2s)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_m2s) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#########################
###Advanced MRA - Lags###
#########################

#Advanced MRA - S2M
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm, data = df_s2m_t)
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm, data = df_s2m_t, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm, data = df_s2m_t, weights = 1/studyobs) #WLS 1/studyobs

model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2)
model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_s2m)
distinct(df_s2m, study_id)
nrow(df_s2m)
lmtest::bptest(model_s2m)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_s2m) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#Advanced MRA - M2S
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t)
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t, weights = 1/studyobs) #WLS 1/studyobs

model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2)
model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_m2s)
distinct(df_m2s, study_id)
nrow(df_m2s)
lmtest::bptest(model_m2s)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_m2s) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#########################
###2. Advanced MRA - Lags + Average time + periode + commodity + z-var + var + ADL + standard GC + TY GC + DP GC + Journal rank + dif +  ###
#########################

#2. Advanced MRA - S2M
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm + commodity_name , data = df_s2m_t) #Welches Model ist das richtige?
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm + dmetal*sqrt(tdf) , data = df_s2m_t)
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm + dmetal , data = df_s2m_t)
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm, data = df_s2m_t, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(tprobit ~ sqrt(tdf) + tm, data = df_s2m_t, weights = 1/studyobs) #WLS 1/studyobs

model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2)
model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_s2m <- lm(t2probit ~ sqrt(tdf) + tm, data = df_s2m_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_s2m)
distinct(df_s2m, study_id)
nrow(df_s2m)
lmtest::bptest(model_s2m)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_s2m) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test

#2. Advanced MRA - M2S
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t)
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(tprobit ~ sqrt(tdf) + tm, data = df_m2s_t, weights = 1/studyobs) #WLS 1/studyobs

model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2)
model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2, weights = sqrt(df)) #WLS sqrt(DF)
model_m2s <- lm(t2probit ~ sqrt(tdf) + tm, data = df_m2s_t2, weights = 1/studyobs) #WLS 1/studyobs

summary(model_m2s)
distinct(df_m2s, study_id)
nrow(df_m2s)
lmtest::bptest(model_m2s)  #Breusch-Pagan test for heteroscedasticity - studentized Breusch-Pagan test
car::ncvTest(model_m2s) #NCV Test for heteroscedasticity - Breusch-Pagan test Non-constant Variance Score Test


#########################################
###Trash - Ignore everything down here###
#########################################

model_all <- lm(tprobit ~ sqrt(tdf) + commodity_name + commodity_name*sqrt(tdf), data = df_all_norm)
summary(model_all)

#PEESE
model_all <- lm(tprobit ~ 1/sqrt(tdf) + sqrt(tdf), data = df_all)

####################################################
###Correlations for idenficiation of colinearity####
####################################################

###DUMMIFY

#data_subset <- df_all[ , c("df", "probit", "tm", "tn")]  #Basicly done befor with samps, pval, m, n but good for selection of df, probit, tm & tn 
#df_precorr <- df_all[complete.cases(data_subset), ] # Omit NAs by columns

#df_corr <- df_precorr[ , unlist(dummy_list)]
#df_corr$TPROBIT <- df_precorr$tprobit
#df_corr$DF <- df_precorr$df
#df_corr$SAMPS <- df_precorr$samps
#df_corr$LAGTM <- df_precorr$tm
#df_corr$LAGTN <- df_precorr$tn

#num.cols <- sapply(df_corr, is.numeric)
#cor.data <- cor(df_corr[,num.cols])
#cor.data

#summary(df_corr)
#summary(cor.data)


###DUMMIFIZIERER
df_precorr <- df_coded[complete.cases(data_subset), ] # Omit NAs by columns

#selector for s2m & m2s
df_precorr <- filter(df_precorr, x_sm == "spec" & y_sm == "market")
df_precorr <- filter(df_precorr, x_sm == "market" & y_sm == "spec")

df_corr <- df_precorr[ , c()]
df_corr$TPROBIT <- df_precorr$tprobit
df_corr$DF <- df_precorr$df
#df_corr$TDF <- df_precorr$tdf
df_corr$SAMPS <- df_precorr$samps
df_corr$START <- year(df_precorr$startyear)
df_corr$END <- year(df_precorr$endyear)
#df_corr$KSM
#df_corr$KMS
df_corr$LAGTM <- df_precorr$tm
df_corr$LAGTN <- df_precorr$tn
#df_corr$TLAGSSM <- ifelse(df_precorr$x_sm == "spec" & df_precorr$y_sm == "market", df_precorr$tm, "")
#df_corr$TLAGSMS <- ifelse(df_precorr$x_sm == "market" & df_precorr$y_sm == "spec", df_precorr$tn, "")
#df_corr$TLAGMSM <- ifelse(df_precorr$x_sm == "spec" & df_precorr$y_sm == "market", df_precorr$tn, "")
#df_corr$TLAGMMS <- ifelse(df_precorr$x_sm == "market" & df_precorr$y_sm == "spec", df_precorr$tm, "")
df_corr$CONTROLS <- ifelse(df_precorr$z_var == "n", 0, 1)
#distinct(select(df_coded, study_id, data_id, z_var), z_var, .keep_all = TRUE)
#distinct(select(filter(df_coded, is.na(z_var)), study_id, data_id, z_var), study_id, .keep_all = TRUE)
#distinct(select(filter(df_corr, CONTROLS == 1), study_id, data_id, CONTROLS), study_id, .keep_all = TRUE)
df_corr$SGC <- ifelse(df_precorr$func_typ == "standard gc", 1, 0)
df_corr$TY <- ifelse(df_precorr$func_typ == "ty gc", 1, 0)
df_corr$publ <- ifelse(df_precorr$type == "article", 1, 0)
distinct(select(df_coded, study_id, data_id, type), type, .keep_all = TRUE)

df_corr$googlecit <- ifelse(is.na(df_precorr$googlecits), 0, df_precorr$googlecits)
#df_corr$CFTC <- ifelse(df_precorr$x_data_source  == "gcftc" | df_precorr$y_data_source  == "cftc", 1, 0)

num.cols <- sapply(df_corr, is.numeric)
cor.data <- cor(df_corr[,num.cols])
cor.data

summary(df_corr)
summary(cor.data)


library(PerformanceAnalytics)
chart.Correlation(df_corr[,3:5])


df_d <- dummy.data.frame(df_all, names=c("country_name", "commodity_name", "x", "y"), sep="_")
df_d <- dummy.data.frame(df_spec2market, names=c("country_name", "commodity_name", "x", "y", "x_sm", "y_sm", "x_sf", "y_sf", "lev_dif", "system", "func_form", "func_typ", "period"), sep="_")
df_d <- dummy.data.frame(df_market2spec, names=c("country_name", "commodity_name", "x", "y", "x_sm", "y_sm", "x_sf", "y_sf", "lev_dif", "system", "func_form", "func_typ", "period"), sep="_")
#df_commodity_dummy <- dummy.data.frame(df_coded, names=c("commodity_name"), sep="_")
#df_commodity_dummy <- dummy.data.frame(df_coded, names=c("x", "y", "x_sf", "y_sf"), sep="_")

###Korrelationen
#Nur Zahlenwerte auswählen
num.cols <- sapply(df_d, is.numeric)
cor.data <- cor(df_d[,num.cols])
cor.data

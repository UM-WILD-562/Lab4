## ----setup, include=FALSE--------------------------------------------------------
require(knitr)
knitr::opts_chunk$set(echo = TRUE)
r <- getOption("repos")
r["CRAN"] <- "https://ftp.osuosl.org/pub/cran/"
options(repos = r)


## ----load packages, include = FALSE----------------------------------------------
#function to install and load required packages
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

#load or install these packages:
packages <- c("tidyverse", "adehabitatHS", "adehabitatHR", "mapview", "tmap", "sf","terra", "here","ggplot2","colorRamps", "stars")

#run function to install packages
ipak(packages)


## ----warning=FALSE---------------------------------------------------------------
landcover<-rast(here::here("Data","landcover"))
image(landcover, col=rainbow(16))
landcover
cats(landcover)
head(values(landcover))
levels(landcover)

##Note we do not have access to the attributes table of HABITATTYPE -- so we have to create one, here we create the legend of HABITATTYPE to ID using previous version of lab 4.

ID <- 0:16
HABITATTYPE <- c("","Open Conifer","Moderate Conifer","Closed Conifer", "Deciduous", "Mixed Forest",
                  "Regeneration","Herbaceous","Shrub","Water","Rock-Ice","Cloud","Burn-Forest",
                  "Burn-Grassland", "Burn-Shrub","Alpine Herb","Alpine Shrub")
values <- as.data.frame(ID) %>% 
  add_column(HABITATTYPE)

#Use the levels function from terra to set the associated HABITAT TYPE attributes

levels(landcover) <- values
cats(landcover)



## ---- warning = FALSE------------------------------------------------------------
landcover

writeRaster(landcover, here::here("Output","landcover16.tif"), overwrite = TRUE)
landcover16 <- rast(here::here("Output","landcover16.tif")) # bringing it back in
landcover16

cats(landcover16)

str(landcover16)
plot(landcover16)


## --------------------------------------------------------------------------------
wolfyht<-st_read("Data/wolfyht.shp")
plot(landcover16, col=rainbow(16))
plot(wolfyht, add=TRUE, type="p", color = "gray25", pch=19, cex = 0.75)

#blanking out mapview for creation of github document
#mapview(landcover16, zcol = "HABITATTYPE") + wolfyht 

#tmap option of interactive maps
#tmap_mode("view")
#landcover_map <- tm_shape(landcover16) + tm_raster()
#landcover_map + tm_shape(wolfyht) + tm_sf()


## --------------------------------------------------------------------------------
## lets make a second plot zooming into a specific area of the Red Deer pack
yht.raster <- rast()
ext(yht.raster) <- c(xmin=570000, xmax=600000, ymin=5720000, ymax=5740000) 	
plot(landcover16, col=rainbow(16), ext=yht.raster)
plot(wolfyht, add=TRUE, type="p", color = "gray25", pch=19)



## ---- eval = FALSE---------------------------------------------------------------
## landcover2<-resample(landcover16, mask.raster, method="ngb")
## extent(landcover2)


## --------------------------------------------------------------------------------
wolfkde <- read.csv("Data/wolfkde5.csv")
table(wolfkde$used, wolfkde$pack)
summary(wolfkde)
#wolfkde <- na.omit(wolfkde)
#summary(wolfkde)
#table(wolfkde$used, wolfkde$pack)


## --------------------------------------------------------------------------------
ggplot(wolfkde, aes(x=EASTING, y = NORTHING, color=usedFactor)) + geom_point() + stat_density2d() + facet_grid(pack ~ ., scales="free")

# or, Facetting by Used
ggplot(wolfkde, aes(x=EASTING, y = NORTHING)) + geom_point() + stat_density2d() + facet_grid(pack ~ usedFactor, scales="free")



## --------------------------------------------------------------------------------
### First for all packs
elev <- glm(used ~ Elevation2, family=binomial(logit), data=wolfkde)
distacc <- glm(used ~ DistFromHumanAccess2, family=binomial(logit), data=wolfkde)
disthha <- glm(used ~ DistFromHighHumanAccess2, family=binomial(logit), data=wolfkde)
sheep <- glm(used ~ sheep_w2, family=binomial(logit), data=wolfkde)
goat <- glm(used ~ goat_w2, family=binomial(logit), data=wolfkde)
elk <- glm(used ~ elk_w2, family=binomial(logit), data=wolfkde)
moose <- glm(used ~ moose_w2, family=binomial(logit), data=wolfkde)
deer <- glm(used ~ deer_w2, family=binomial(logit), data=wolfkde)


## --------------------------------------------------------------------------------
models = rbind(summary(elev)$coefficients[,1:2], summary(disthha)$coefficients[,1:2], summary(distacc)$coefficients[,1:2], summary(sheep)$coefficients[,1:2], summary(goat)$coefficients[,1:2], summary(elk)$coefficients[,1:2], summary(moose)$coefficients[,1:2], summary(deer)$coefficients[,1:2])
# Name your models
modelnames = c("elev","disthha", "distacc", "sheep", "goat", "elk", "moose", "deer")
# Now put all of your estimates in a pretty table with names that you'll remember!
estimates.all = matrix(models, nrow=2*length(modelnames), ncol=2, dimnames = list(paste(rep(modelnames, each=2),c("intercept", "coefficient")), c("B", "SE")))
estimates.all
plot(estimates.all)


## --------------------------------------------------------------------------------
levels(wolfkde$landcover16) ## see, all we have is landcover code

wolfkde$habitatType = ifelse(wolfkde$landcover16 == 0, "NA", 
                            ifelse(wolfkde$landcover16 == 1, "Open Conifer", 
                            ifelse(wolfkde$landcover16 == 2, "Moderate Conifer", 
                            ifelse(wolfkde$landcover16 == 3, "Closed Conifer", 
                            ifelse(wolfkde$landcover16 == 4, "Deciduous", 
                            ifelse(wolfkde$landcover16 == 5, "Mixed", 
                            ifelse(wolfkde$landcover16 == 6, "Regen", 
                            ifelse(wolfkde$landcover16 == 7, "Herbaceous",                 
                            ifelse(wolfkde$landcover16 == 8, "Shrub",                       
                            ifelse(wolfkde$landcover16 == 9, "Water", 
                            ifelse(wolfkde$landcover16 == 10, "Rock-Ice", 
                            ifelse(wolfkde$landcover16 == 11, "Cloud", 
                            ifelse(wolfkde$landcover16 == 12, "Burn-Forest",               
                            ifelse(wolfkde$landcover16 == 13, "Burn-Grassland", 
                            ifelse(wolfkde$landcover16 == 14, "Burn-Shrub", 
                            ifelse(wolfkde$landcover16 == 15, "Alpine Herb", "Alpine Shrub"))))))))))))))))

table(wolfkde$landcover16, wolfkde$used)


## --------------------------------------------------------------------------------
table(wolfkde$habitatType, wolfkde$usedFactor)
ggplot(wolfkde, aes(x=landcover16, y=..density.., fill = used)) +geom_histogram(binwidth = 1) + facet_grid(used~.)



## --------------------------------------------------------------------------------
wolfkde2 <- wolfkde[wolfkde$landcover16 != 11, ]
wolfkde3 <-wolfkde2[wolfkde2$landcover16 != 0, ]
table(wolfkde3$habitatType, wolfkde3$usedFactor)


## --------------------------------------------------------------------------------
names.m = data.frame(unique(wolfkde3$landcover16),unique(wolfkde3$habitatType))
# Now I put it order
names.m = names.m[order(names.m)[1:15],]
names.m


## --------------------------------------------------------------------------------
wolfkde3$landcov.f = factor(wolfkde3$landcover16,labels = names.m$unique.wolfkde3.habitatType)


## --------------------------------------------------------------------------------
table(wolfkde3$landcov.f, wolfkde3$usedFactor)
table(wolfkde3$landcov.f, wolfkde3$landcover16)


## --------------------------------------------------------------------------------
table(wolfkde3$habitatType, wolfkde3$usedFactor)


## --------------------------------------------------------------------------------
landcovSelection <- table(wolfkde3$habitatType, wolfkde3$usedFactor)
landcovSelection2 <- as.data.frame.matrix(landcovSelection)
colnames(landcovSelection2)[1:2] <- c("avail","used")
## Calculate Proportional Availability
sum(landcovSelection2$used)
landcovSelection2$pUse <- landcovSelection2$used /413
sum(landcovSelection2$avail)
landcovSelection2$pAvail <- landcovSelection2$avail /1996 # note 2000 because of censored cloud and NA's. 
landcovSelection2


## --------------------------------------------------------------------------------
landcovSelection2$selection <- landcovSelection2$pUse / landcovSelection2$pAvail
plot(landcovSelection2$selection)


## --------------------------------------------------------------------------------
landcovSelection2$selectionN <- landcovSelection2$used / landcovSelection2$avail
plot(landcovSelection2$selection, landcovSelection2$selectionN)


## --------------------------------------------------------------------------------
landcovSelection2


## --------------------------------------------------------------------------------
landcovSelection2$lnSelection <- log(landcovSelection2$selection)

## Lets make a new column of habitatType
landcovSelection2$landcoverType <- c("Alpine Herb", "Alpine Shrub", "Burn-Forest", "Burn-Grassland", "Burn-Shrub", "Closed Conifer", "Deciduous", "Herbaceous", "Mixed", "Moderate Conifer" ,"Open Conifer", "Regen", "Rock-Ice", "Shrub", "Water")
                          

## lets make a plot of the Manly (ln) Selectivity Coefficients
ggplot(data=landcovSelection2, aes(x=landcoverType, y = lnSelection)) + geom_point(size=4) + theme(axis.text.x = element_text(angle = 90))


## --------------------------------------------------------------------------------
## it might be handy to save this
write.table(landcovSelection2, "Data/wolfselection.csv", sep=",", row.names = TRUE, col.names=TRUE)
#str(landcovSelection2)


## --------------------------------------------------------------------------------
## Selection ratio
ggplot(landcovSelection2, aes(x=landcoverType, y = selection)) + geom_bar(stat="Identity") + theme(axis.text.x = element_text(angle = 90))
## Ln-Selection Ratio
ggplot(landcovSelection2, aes(x=landcoverType, y = lnSelection)) + 
geom_bar(stat="Identity") + theme(axis.text.x = element_text(angle = 90))


## --------------------------------------------------------------------------------
## Fancier ggplot
ggplot(landcovSelection2, aes(x=selection, y = lnSelection)) + stat_smooth()


## --------------------------------------------------------------------------------
## Estimated available proportions on design I data
elk.avail <- c(15, 61, 84, 40)
elk.used <- c(3, 90, 181, 51)
names(elk.used) <- c("0%", "1-25%", "26-75%", ">75%")
names(elk.avail) <- names(elk.used)
## Computation of wi
(wiRatio <- widesI(elk.used, elk.avail, avknown=FALSE))

## plot the values of the selection ratios
plot(wiRatio)


## --------------------------------------------------------------------------------
contrasts(wolfkde3$landcov.f) = contr.treatment(15) 
### To see the design matrix assigned
attributes(wolfkde3$landcov.f)
levels(wolfkde3$landcov.f)


## --------------------------------------------------------------------------------
levels(wolfkde3$landcov.f)[11:13] = "Burn"
## note this then reduces us from 15 to 13 categories
contrasts(wolfkde3$landcov.f) = contr.treatment(13)
attributes(wolfkde3$landcov.f)


## --------------------------------------------------------------------------------
naive.nf = glm(used~landcover16,data=wolfkde3, family=binomial(logit))
summary(naive.nf)


## --------------------------------------------------------------------------------
oc = glm(used~I(landcov.f=="Open Conifer"),data=wolfkde3, family = binomial(logit))
summary(oc)
#str(summary(oc))


## --------------------------------------------------------------------------------
exp(-1.622+0.711*1)/(1+exp(-1.622+0.711*1))
## now compare to the probability of wolf use in non-conifer landcovers ?
exp(-1.622+0.711*0)/(1+exp(-1.622+0.711*0))


## --------------------------------------------------------------------------------
landcovSelection2


## --------------------------------------------------------------------------------
## with just open conifer and burns
ocb = glm(used~I(landcov.f=="Open Conifer")+I(landcov.f=="Burn"), data = wolfkde3, family = binomial(logit))
summary(ocb)

### and with a few more variables
conif = glm(used~I(landcov.f=="Open Conifer")+I(landcov.f=="Moderate Conifer")
                  +I(landcov.f=="Closed Conifer"), data = wolfkde3, family = binomial(logit))
summary(conif)


## --------------------------------------------------------------------------------
# Full model
full = glm(used~I(landcov.f), data=wolfkde3, family = binomial(logit))
summary(full)


## --------------------------------------------------------------------------------
table(wolfkde3$landcov.f, wolfkde3$usedFactor)


## --------------------------------------------------------------------------------
exp(-0.974 - 15.592*1)/(1+exp(-0.974 - 15.592*1)) 


## --------------------------------------------------------------------------------
full.NoInt = glm(used~I(landcov.f) -1, data=wolfkde3, family = binomial(logit))
summary(full.NoInt)


## --------------------------------------------------------------------------------
full.model = glm(used~I(landcov.f=="Moderate Conifer")+I(landcov.f=="Closed Conifer") +I(landcov.f=="Deciduous")+I(landcov.f=="Mixed")+I(landcov.f=="Herbaceous")+I(landcov.f=="Regen")+I(landcov.f=="Shrub")+I(landcov.f=="Water")+I(landcov.f=="Rock-Ice") +I(landcov.f=="Burn")+I(landcov.f=="Alpine Herb")+I(landcov.f=="Alpine Shrub"), data = wolfkde3, family = binomial(logit))
summary(full.model)


## --------------------------------------------------------------------------------
## first recheck which # Rock-Ice is
levels(wolfkde3$landcov.f) ## Ok it is # 10

contrasts(wolfkde3$landcov.f) = contr.treatment(13, base = 10)
attributes(wolfkde3$landcov.f)
# and note that rock-ice now is 0. 

rockintercept.model = glm(used~I(landcov.f=="Moderate Conifer") +I(landcov.f=="Closed Conifer") +I(landcov.f=="Deciduous")+I(landcov.f=="Mixed")+I(landcov.f=="Herbaceous") +I(landcov.f=="Regen")+I(landcov.f=="Shrub")+I(landcov.f=="Water")+I(landcov.f=="Open Conifer")+I(landcov.f=="Burn")+I(landcov.f=="Alpine Herb")+I(landcov.f=="Alpine Shrub"), data = wolfkde3, family = binomial(logit))
summary(rockintercept.model)


## --------------------------------------------------------------------------------
wolfkde3$closedConif = ifelse(wolfkde3$habitatType == "Closed Conifer", 1, 0)
wolfkde3$modConif = ifelse(wolfkde3$habitatType == "Moderate Conifer", 1, 0)
wolfkde3$openConif = ifelse(wolfkde3$habitatType == "Open Conifer", 1, 0)
wolfkde3$decid = ifelse(wolfkde3$habitatType == "Deciduous", 1, 0)
wolfkde3$regen = ifelse(wolfkde3$habitatType == "Regen", 1, 0)
wolfkde3$mixed = ifelse(wolfkde3$habitatType == "Mixed", 1, 0)
wolfkde3$herb = ifelse(wolfkde3$habitatType == "Herbaceous", 1, 0)
wolfkde3$shrub = ifelse(wolfkde3$habitatType == "Shrub", 1, 0)
wolfkde3$water = ifelse(wolfkde3$habitatType == "Water", 1, 0)
wolfkde3$rockIce = ifelse(wolfkde3$habitatType == "Rock-Ice", 1, 0)
## note here I reclassified all burn = 1 
wolfkde3$burn = ifelse(wolfkde3$habitatType == "Burn-Grassland", 1, ifelse(wolfkde3$habitatType == "Burn-Shrub", 1, ifelse(wolfkde3$habitatType == "Burn-Forest", 1,0 )))
wolfkde3$alpineHerb = ifelse(wolfkde3$habitatType == "Alpine Herb", 1, 0)
wolfkde3$alpineShrub = ifelse(wolfkde3$habitatType == "Alpine Shrub", 1, 0)

head(wolfkde3)


## --------------------------------------------------------------------------------
wolfkde3$alpine = wolfkde3$alpineHerb + wolfkde3$alpineShrub


## --------------------------------------------------------------------------------
oc.intercept.model = glm(used~closedConif + modConif + decid+ regen+mixed+herb+water+rockIce+burn+alpine, data = wolfkde3, family = binomial(logit))
summary(oc.intercept.model)

### refitting model with just Alpine and Rock and Ice as the intercept
rockintercept.alpine.model = glm(used~closedConif + openConif + modConif + decid+ regen+mixed+herb+water+burn+alpine, data = wolfkde3, family = binomial(logit))
summary(rockintercept.alpine.model)

### refitting model manually dropping Decid and Regen - where do they no go?
rock.alpine.regen.decid.intercept.model = glm(used~closedConif + openConif + modConif + mixed+herb+water+burn+alpine, data = wolfkde3, family = binomial(logit))
summary(rock.alpine.regen.decid.intercept.model)


## --------------------------------------------------------------------------------
rockintercept.alpine.model.df <- data.frame(summary(rockintercept.alpine.model)$coefficients[,1:2])
oc.intercept.model.df <- data.frame(summary(oc.intercept.model)$coefficients[,1:2])
coef.table <- rbind(rockintercept.alpine.model.df,oc.intercept.model.df)
coef.table$habitatType <- c(row.names((summary(rockintercept.alpine.model)$coefficients[,1:2])),row.names(summary(oc.intercept.model)$coefficients[,1:2]))
coef.table$habitatType[1] <- "rockIce"
coef.table$habitatType[12] <- "openConif"
coef.table$model <-c(rep("Open Conif Intercept",11),rep( "RockIce Intercept",11))
coef.table


## --------------------------------------------------------------------------------
ggplot(coef.table, aes(x=habitatType, y=Estimate, colour=model)) + geom_point(size = 5) + theme(axis.text.x = element_text(angle = 90))


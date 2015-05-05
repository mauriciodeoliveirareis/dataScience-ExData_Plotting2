
#Find a way to plot a USA map
#Find a FIPS table to relate to state
#if the slqdf lib is not installed, install it
if(!"sqldf" %in% rownames(installed.packages())) {
  install.packages("sqldf")
}
if(!"maps" %in% rownames(installed.packages())) {
  install.packages("maps")
}
if(!"mapproj" %in% rownames(installed.packages())) {
  install.packages("mapproj")
}
if(!"stringr" %in% rownames(installed.packages())) {
  install.packages("stringr")
}


#Loads sql lib
library(sqldf)
#loads stringr
library(stringr)
#Loads maps libs
require(maps)
require(mapproj)

#Read the data frames
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")
fipsTable <- read.csv(file = "fipsTable.csv", sep = ',', header = TRUE)
#Replaces col names by _ to be able to use sql lib
colnames(SCC) <- gsub("\\.","_",colnames(SCC))
#gets total emissions in Baltimore City, Maryland (fips = '24510') for each type and 
#formats fips to have the state prefix (two first digits)
coalRelatedNEI <- sqldf("select n.*, SUBSTR(n.FIPS, 1, 2) as 'stateFIPS' FROM NEI n, SCC s WHERE n.SCC = s.SCC and s.EI_Sector like '%Coal%'")
#adds the state name based on a FIPS table 
coalRelatedNEI <- sqldf("select n.*, s.StateName as 'StateName' FROM coalRelatedNEI n, fipsTable s WHERE n.stateFIPS = s.FIPS")
#calculates the total by state in 1999
totByState <- sqldf("select StateName, SUM(Emissions) as 'totalEmissions1999' from coalRelatedNEI WHERE year =  '1999' GROUP BY StateName ORDER BY StateName" )
totByState <- cbind(totByState, sqldf("select SUM(Emissions) as 'totalEmissions2008' from coalRelatedNEI WHERE year =  '2008' GROUP BY StateName ORDER BY StateName" ))
#verifies where the polution has increased the increased areas will be red and the decrease will be black
polutionIncreasedColor <- ifelse((totByState$totalEmissions2008 > totByState$totalEmissions1999), "#FF0000", "#000000")
totByState <- cbind(totByState, polutionIncreasedColor)
#puts state names in lower case to make easy to find then
totByState$StateName <- tolower(totByState$StateName)

# define color buckets

leg.txt <- c("Increased", "Decreased")
mapStatesNames <- data.frame(state=map("state", plot=FALSE)$names)
#create a column without the : area
stateDetailLocation <- str_locate(mapStatesNames$state, ":")
#adds a column in the maps states names without the details of the region e. g. :lopez island
stateWithoutDetail <- str_sub(mapStatesNames$state, 0, ifelse(is.na(stateDetailLocation), 99999, stateDetailLocation -1 ))
mapStatesNames <- cbind(mapStatesNames, stateWithoutDetail)
#creates a table with the state and its respective color
stateColors <- sqldf("select t.polutionIncreasedColor,  m.state as 'mapStateName' from totByState t, mapStatesNames m WHERE t.StateName  like  m.stateWithoutDetail GROUP BY t.polutionIncreasedColor,  m.state" )
#matches the colors with the state list name fro map to plot it on map
colorsmatched <- stateColors$polutionIncreasedColor[match(map("state", plot=FALSE)$names, stateColors$mapStateName, nomatch=1)]

png(file="plot4.png", width = 480, height = 480)
# draw map
map("state", col = colorsmatched, fill = TRUE, resolution = 0,
    lty = 1, projection = "polyconic")

title("States that had increased pollution lvl from 1999 to 2008")
legend("topright", leg.txt, horiz = TRUE, fill = c("#FF0000", "#000000"), cex=0.75)

dev.off()
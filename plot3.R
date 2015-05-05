#if the slqdf lib is not installed, install it
if(!"sqldf" %in% rownames(installed.packages())) {
install.packages("sqldf")
}
#if the ggplot2 lib is not installed, install it
if(!"ggplot2" %in% rownames(installed.packages())) {
install.packages("ggplot2")
}
#Loads sql lib
library(sqldf)
#Loads ggplot2 lib
library(ggplot2)
getScaledPercentage <- function(valVector) {
  maxValue <- max(valVector)
  
  return(sapply(valVector, function(valVector) {    
    return ((valVector / maxValue) * 100) 
  } ))
}

addTotalEmissionRelativeToMax <- function(dataFrame) {
  totalEmissionRelativeToMax <- getScaledPercentage(dataFrame$TotalEmissions)
  dataFrame <- cbind(dataFrame, totalEmissionRelativeToMax)
  return (dataFrame)
}

#Read the data frames
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")
#gets total emissions in Baltimore City, Maryland (fips = '24510') for each type
pointTotal <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year', 'Point' AS 'type'  from NEI WHERE fips = '24510' AND type = 'POINT' GROUP BY year ORDER BY year")
nonPointTotal <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year', 'Non Point' AS 'type' from NEI WHERE fips = '24510' AND type = 'NONPOINT' GROUP BY year ORDER BY year")
onRoadTotal <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year', 'On Road' AS 'type' from NEI WHERE fips = '24510' AND type = 'ON-ROAD' GROUP BY year ORDER BY year")
nonRoadTotal <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year', 'Non Road' AS 'type' from NEI WHERE fips = '24510' AND type = 'NON-ROAD' GROUP BY year ORDER BY year")
#scale Total Emission to clear visualization of what is increasing and what is decreasing
pointTotal <- addTotalEmissionRelativeToMax(pointTotal)

nonPointTotal <- addTotalEmissionRelativeToMax(nonPointTotal)

onRoadTotal <- addTotalEmissionRelativeToMax(onRoadTotal)

nonRoadTotal <- addTotalEmissionRelativeToMax(nonRoadTotal)

#put all the totals in one table
allTotal <- rbind(pointTotal, nonPointTotal, onRoadTotal, nonRoadTotal)

png(file="plot3.png", width = 480, height = 480)
qplot(Year, totalEmissionRelativeToMax, data = allTotal, geom = c("point", "line"), colour = type, main = "Relative Emissions Variation by Type")
dev.off()
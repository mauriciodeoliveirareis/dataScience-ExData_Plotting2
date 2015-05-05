#if the slqdf lib is not installed, install it
if(!"sqldf" %in% rownames(installed.packages())) {
  install.packages("sqldf")
}
#if the ggplot2 lib is not installed, install it
if(!"ggplot2" %in% rownames(installed.packages())) {
  install.packages("ggplot2")
}

if(!"Hmisc" %in% rownames(installed.packages())) {
  install.packages("Hmisc")
}  
#Loads sql lib
library(sqldf)
#Loads ggplot2 lib
library(ggplot2)
library(Hmisc)
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
#Replaces col names by _ to be able to use sql lib
colnames(SCC) <- gsub("\\.","_",colnames(SCC))
#gets just scc related to motor Vehicle sources
sccVehicle <- sqldf("select * from SCC WHERE EI_Sector like '%vehicle%'")
#Gets the sum of emissions in Baltimore City, Maryland (fips = '24510') for vehicles
emissionsBatimore <- sqldf("select SUM(n.Emissions) as 'TotalEmissions', n.year as 'Year', 'Baltimore City' as Region from NEI n, sccVehicle s WHERE n.SCC = s.SCC AND n.fips = '24510' GROUP BY n.year ORDER BY n.year")
#Gets the sum of emissions in Los Angeles County, California (fips = '06037') for vehicles
emissionsLosAngeles <- sqldf("select SUM(n.Emissions) as 'TotalEmissions', n.year as 'Year', 'Los Angeles County' as Region from NEI n, sccVehicle s WHERE n.SCC = s.SCC AND n.fips = '06037'  GROUP BY n.year ORDER BY n.year")

emissionsBatimore <- addTotalEmissionRelativeToMax(emissionsBatimore)
emissionsLosAngeles <- addTotalEmissionRelativeToMax(emissionsLosAngeles)

#put all the totals in one table
allTotal <- rbind(emissionsBatimore, emissionsLosAngeles)

png(file="plot6.png", width = 480, height = 480)
qplot(Year, totalEmissionRelativeToMax, data = allTotal, geom = c("point", "line"), colour = Region, main = "Relative Total Vehicle Source Emissions Variation by City")
dev.off()
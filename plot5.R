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
#Read the data frames
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")
#Replaces col names by _ to be able to use sql lib
colnames(SCC) <- gsub("\\.","_",colnames(SCC))
#gets just scc related to motor Vehicle sources
sccVehicle <- sqldf("select * from SCC WHERE EI_Sector like '%vehicle%'")
#Gets emissions in Baltimore City, Maryland (fips = '24510') for vehicles
emissions <- sqldf("select SUM(n.Emissions) AS 'TotalEmissions', n.year as 'Year'  from NEI n, sccVehicle s WHERE n.SCC = s.SCC AND n.fips = '24510' GROUP BY n.year ORDER BY n.year")



png(file="plot5.png", width = 480, height = 480)
qplot(Year, TotalEmissions, data = emissions, geom = c("point", "line"), main = "Total Vehicle Sources Emissions for Baltimore City")
dev.off()
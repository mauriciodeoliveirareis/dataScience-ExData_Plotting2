#if the slqdf lib is not installed, install it
if(!"sqldf" %in% rownames(installed.packages())) {
install.packages("sqldf")
}
#Loads sql lib
library(sqldf)
#Read the data frames
NEI <- readRDS("summarySCC_PM25.rds")
#gets total emissions in Baltimore City, Maryland (fips = '24510')
totEmissionsBalPerYr <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year' from NEI WHERE fips = '24510' GROUP BY year ORDER BY year")
png(file="plot2.png", width = 400, height = 400)
plot(totEmissionsBalPerYr$Year, totEmissionsBalPerYr$TotalEmissions, 
     type = "b", 
     col = "red", 
     lwd = 3,
     xlab = "Year",
     ylab = "Total Emissions",
     main = "Total Emissions Per Year Baltimore City, Maryland")
fit1 <- lm (TotalEmissions ~ Year, data = totEmissionsBalPerYr) 
abline(fit1, lty = "dashed")
dev.off()
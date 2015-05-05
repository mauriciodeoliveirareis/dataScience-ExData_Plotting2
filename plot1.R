#if the slqdf lib is not installed, install it
if(!"sqldf" %in% rownames(installed.packages())) {
  install.packages("sqldf")
}
#Loads sql lib
library(sqldf)
#Read the data frames
NEI <- readRDS("summarySCC_PM25.rds")
totEmissionsPerYr <- sqldf("select SUM(Emissions) as 'TotalEmissions', year as 'Year' from NEI GROUP BY year ORDER BY year")
png(file="plot1.png", width = 400, height = 400)
plot(totEmissionsPerYr$Year, totEmissionsPerYr$TotalEmissions, 
     type = "b", 
     col = "red", 
     lwd = 3,
     xlab = "Year",
     ylab = "Total Emissions",
     main = "Total Emissions Per Year")
fit1 <- lm (TotalEmissions ~ Year, data = totEmissionsPerYr) 
abline(fit1, lty = "dashed")
dev.off()
--QUERY 1 - Fact Count
--Get count of when flights occured in our data set. 
--Note that the AirlinePerfomance-OLTP database contains flight data from all of 2016 but the AirlinePerfomance-ODS only contains December 2016
SELECT [Calendar Year], [Month], COUNT(*) [Count]
FROM ADF.FlightFact F
INNER JOIN ADF.DimDate D
ON F.FlightDateKey = D.DateKey
GROUP BY [Calendar Year],[Month]

--QUERY 2 - Busiest Origin Airports
--Get our top 100 busiest airports by originating flight
SELECT TOP 100
	[City_Airport], COUNT(*) [Count]
FROM ADF.FlightFact F
INNER JOIN ADF.DimDate D
ON F.FlightDateKey = D.DateKey
INNER JOIN ADF.DimAirport A
ON F.OriginAirportKey = A.[Key]
WHERE
	[Calendar Year] = 2016 and [Calendar Month Number] = 12
GROUP BY
	[City_Airport]
ORDER BY
	COUNT(*) DESC

--QUERY 3 - Most Used Planes
--Get our top 20 most used plane models, this uses the FAA dataset that was originated from Amazon S3 and merged via Hive
SELECT TOP 20
	[Mfr-Name],[Model-Name], COUNT(*) [Count]
FROM ADF.FlightFact F
INNER JOIN ADF.DimDate D
ON F.FlightDateKey = D.DateKey
INNER JOIN ADF.DimAircraft Ac
ON F.AircraftKey = Ac.[Key]
WHERE
	[Calendar Year] = 2016 and [Calendar Month Number] = 12
GROUP BY
	[Mfr-Name],[Model-Name]
ORDER BY
	COUNT(*) DESC

--QUERY 4 - Average Delay by Day in MSP and Weather
--Get the Average delay for each day in December at MSP along with the weather data source from our REST source. Remember, this weather data was randomly generated.
--Used Origin airport as delays tend to affect outgoing flights more
SELECT
	D.[Date], A.[Code] as Airport, OriginAirportTempF as TemperatureF, AVG(DEP_Delay) AS Average_Departure_Delay_Mins
FROM ADF.FlightFact F
INNER JOIN ADF.DimDate D
ON F.FlightDateKey = D.DateKey
INNER JOIN ADF.DimAirport A
ON F.OriginAirportKey = A.[Key]
WHERE
	[Calendar Year] = 2016 and [Calendar Month Number] = 12
	AND
	[Code] = 'MSP'
GROUP BY
	[Date], A.[Code], OriginAirportTempF
ORDER BY
	D.[Date]


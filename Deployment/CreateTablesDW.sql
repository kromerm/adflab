/****** Object:  Table [dbo].[DimAircraft]    Script Date: 12/20/2017 4:11:54 PM ******/
SET ANSI_NULLS ON
;

SET QUOTED_IDENTIFIER ON
;

CREATE TABLE [dbo].[DimAircraft]
(
	[Key] [int] IDENTITY(1,1) NOT NULL,
	[N-Number] [nvarchar](255) NULL,
	[Serial Number] [nvarchar](255) NULL,
	[MFR MDL Code] [nvarchar](255) NULL,
	[Eng MFR Code] [nvarchar](255) NULL,
	[Year MFR] [nvarchar](255) NULL,
	[Type Registrant] [nvarchar](255) NULL,
	[Last Activity Date] [nvarchar](255) NULL,
	[Cert Issue Date] [nvarchar](255) NULL,
	[Type Aircraft] [nvarchar](255) NULL,
	[Type Engine] [nvarchar](255) NULL,
	[Status Code] [nvarchar](255) NULL,
	[Mode S Code] [nvarchar](255) NULL,
	[Airworthiness Date] [nvarchar](255) NULL,
	[Unique ID] [nvarchar](255) NULL,
	[Kit MFR Code] [nvarchar](255) NULL,
	[Kit Model] [nvarchar](255) NULL,
	[MFR-NAME] [nvarchar](255) NULL,
	[MODEL-NAME] [nvarchar](255) NULL,
	[TYPE-AIRCRAFT] [nvarchar](255) NULL,
	[TYPE-ENGINE] [nvarchar](255) NULL,
	[AC-CATE;RY] [nvarchar](255) NULL,
	[AMAT-TC-BUILT] [nvarchar](255) NULL,
	[NUMBER-ENGINES] [nvarchar](255) NULL,
	[NUMBER-SEATS] [nvarchar](255) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
;

/****** Object:  Table [dbo].[DimAirline]    Script Date: 12/20/2017 4:11:55 PM ******/
SET ANSI_NULLS ON
;

SET QUOTED_IDENTIFIER ON
;

CREATE TABLE [dbo].[DimAirline]
(
	[Key] [int] IDENTITY(1,1) NOT NULL,
	[Code] [int] NOT NULL,
	[Airline_Code] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
;

/****** Object:  Table [dbo].[DimAirport]    Script Date: 12/20/2017 4:11:55 PM ******/
SET ANSI_NULLS ON
;

SET QUOTED_IDENTIFIER ON
;

CREATE TABLE [dbo].[DimAirport]
(
	[Key] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[City_Airport] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
;

/****** Object:  Table [dbo].[DimDate]    Script Date: 12/20/2017 4:11:56 PM ******/
SET ANSI_NULLS ON
;

SET QUOTED_IDENTIFIER ON
;

CREATE TABLE [dbo].[DimDate]
(
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day Number] [int] NOT NULL,
	[Day] [nvarchar](10) NOT NULL,
	[Month] [nvarchar](10) NOT NULL,
	[Short Month] [nvarchar](3) NOT NULL,
	[Calendar Month Number] [int] NOT NULL,
	[Calendar Month Label] [nvarchar](20) NOT NULL,
	[Calendar Year] [int] NOT NULL,
	[Calendar Year Label] [nvarchar](10) NOT NULL,
	[Fiscal Month Number] [int] NOT NULL,
	[Fiscal Month Label] [nvarchar](20) NOT NULL,
	[Fiscal Year] [int] NOT NULL,
	[Fiscal Year Label] [nvarchar](10) NOT NULL,
	[ISO Week Number] [int] NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
;

/****** Object:  Table [dbo].[FlightFact]    Script Date: 12/20/2017 4:11:56 PM ******/
SET ANSI_NULLS ON
;

SET QUOTED_IDENTIFIER ON
;

CREATE TABLE [dbo].[FlightFact]
(
	[FlightDateKey] [int] NOT NULL,
	[AircraftKey] [int] NOT NULL,
	[UNIQUE_CARRIER] [varchar](50) NULL,
	[AirlineKey] [int] NOT NULL,
	[CARRIER] [varchar](50) NULL,
	[FL_NUM] [int] NOT NULL,
	[ORIGIN_AIRPORT_ID] [int] NOT NULL,
	[ORIGIN_AIRPORT_SEQ_ID] [int] NULL,
	[ORIGIN_CITY_MARKET_ID] [int] NULL,
	[DEST_AIRPORT_ID] [int] NOT NULL,
	[DEST_AIRPORT_SEQ_ID] [int] NULL,
	[DEST_CITY_MARKET_ID] [int] NULL,
	[DEP_TIME] [varchar](50) NULL,
	[DEP_DELAY] [float] NULL,
	[DEP_DELAY_NEW] [float] NULL,
	[TAXI_OUT] [float] NULL,
	[WHEELS_OFF] [varchar](50) NULL,
	[WHEELS_ON] [varchar](50) NULL,
	[TAXI_IN] [float] NULL,
	[ARR_TIME] [varchar](50) NULL,
	[ARR_DELAY] [float] NULL,
	[ARR_DELAY_NEW] [float] NULL,
	[CANCELLED] [bit] NULL,
	[CANCELLATION_CODE] [varchar](50) NULL,
	[ACTUAL_ELAPSED_TIME] [float] NULL,
	[AIR_TIME] [float] NULL,
	[FLIGHTS] [int] NULL,
	[DISTANCE] [int] NULL,
	[CARRIER_DELAY] [float] NULL,
	[WEATHER_DELAY] [float] NULL,
	[NAS_DELAY] [float] NULL,
	[SECURITY_DELAY] [float] NULL,
	[LATE_AIRCRAFT_DELAY] [float] NULL,
	[DestAirportKey] [int] NULL,
	[OriginAirportKey] [int] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
;



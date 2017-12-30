CREATE DATABASE if not exists ADFLAB;
CREATE EXTERNAL TABLE if not exists ADFLAB.FAAMaster
(
    N_Number string,
	Serial_Number string ,
	MFR_MDL_Code string ,
	Eng_MFR_Code string ,
	Year_MFR string ,
	Type_Registrant string ,
	Name string ,
	Street1 string ,
	Street2 string ,
	City string ,
	State string ,
	ZIP string ,
	Region string ,
	County  string ,
	Country string ,
	Last_Activity_Date string ,
	Cert_Issue_Date string ,
	Certification_Requested  string ,
	Type_Aircraft string ,
	Type_Engine string ,
	Status_Code string ,
	Mode_S_Code string ,
	Fractional_Ownership string ,
	Airworthiness_Date string ,
	OtherName1 string ,
	OtherName2 string ,
	OtherName3 string ,
	OtherName4 string ,
	OtherName5 string ,
	Expiration_Date string ,
	Unique_ID string ,
	Kit_MFR_Code string ,
	Kit_Model string ,
	MoseSCodeHex string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
LOCATION 'wasb://input@adflabstaging.blob.core.windows.net/FAAmaster' TBLPROPERTIES("skip.header.line.count"="1");

CREATE EXTERNAL TABLE if not exists ADFLAB.FAAaircraft
(
    MFR_NAME string,
	MODEL_NAME string,
	TYPE_AIRCRAFT string,
	TYPE_ENGINE string,
	AC_CATEGORY string,
	AMAC_TC_BUILT string,
	NUMBER_ENGINES string,
	NUMBER_SEATS string,
	AC_WEIGHT string,
	SPEED string,
	MFR_MDL_CODE string,
	KIT_CODE string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
LOCATION 'wasb://input@adflabstaging.blob.core.windows.net/FAAaircraft' TBLPROPERTIES("skip.header.line.count"="1");

CREATE TABLE if not exists ADFLAB.Dummy
(
	Some_key tinyint
);

USE ADFLAB;

INSERT INTO Dummy VALUES (1);

insert overwrite directory 'wasb://output@adflabstaging.blob.core.windows.net/FAAMerge' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
SELECT
	N_Number,Serial_Number,Year_MFR,MFR_Name,Model_Name,Number_Engines,Number_Seats, sort_col
FROM
(
  SELECT
  	0 as sort_col,
  	'N_Number' as N_Number,
    'Serial_Number' as Serial_Number,
    'Year_MFR' as Year_MFR,
    'MFR_Name' as MFR_Name,
    'Model_Name' as Model_Name,
    'Number_Engines' as Number_Engines,
    'Number_Seats' as Number_Seats
  FROM
  	Dummy
  UNION ALL
  SELECT 
	  1 as sort_col, N_Number,Serial_Number,Year_MFR,MFR_Name,Model_Name,Number_Engines,Number_Seats
  FROM
	  FAAmaster M
  JOIN
	  FAAaircraft A
  ON (M.MFR_MDL_CODE = A.MFR_MDL_CODE)
 ) U
 ORDER BY 
 	sort_col ASC;
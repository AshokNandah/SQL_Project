

----/ Creating Database ----

CREATE DATABASE "CDMS"

SELECT * FROM country_master

SELECT * FROM industry_master

select * FROM co2world_wide

select * FROM co2country_industry
select DISTINCT unit FROM co2country_industry

select * FROM forest_change

select * FROM GDP_growth

select  * FROM greenhouse

select  * FROM surface_change

select  * FROM sea_level

select  * FROM GDP_VALUE

---/.deleting coloum from table/---

ALTER TABLE greenhouse
DROP COLUMN gcountry_code;

ALTER TABLE co2world_wide
DROP COLUMN world;

ALTER TABLE co2country_industry
DROP COLUMN Industry;

---/ 1)-co2 emmission table extraction- extracting from co2 worldwide /---
--/ Parts per million /----
---Monthly Atmospheric Carbon Dioxide Concentrations PPM---

SELECT Year, Unit , value as emission, Date as date
FROM CO2world_wide
WHERE Unit IN ('Parts Per Million') AND Year >1990 
ORDER BY Year;

---/2) Percent level - co2 worldwide
----Monthly Atmospheric Carbon Dioxide percentage

SELECT Year, Unit , value as emission, Date as date
FROM CO2world_wide
WHERE Unit IN ('Percent') AND Year >1990 
ORDER BY Year;

---/3)-surface change- YTD  temprature change (average)
------Average Temperature Change Over Years line
-----Average Temperature Change Over Years bar - tend analysis

SELECT Year, AVG(temp_change) as Temp_change
FROM surface_change
WHERE Year > 1985
GROUP BY year
ORDER BY year;

----/ 4) temprature change  for top 14 countries/---
-----Average Temperature Change Over Years top14 countries

select c.Country, Year,AVG(temp_change) as tem_change From
surface_change
LEFT JOIN country_master  c on c.Country_code = scountry_code
WHERE c.Country in ('United States', 'China', 'Japan', 'Germany', 'United Kingdom', 
    'India', 'France', 'Brazil', 'Italy', 'Canada', 'Australia', 
    'Spain', 'Netherlands', 'Saudi Arabia', 'Switzerland', 'Argentina')
GROUP BY c.Country, Year
ORDER BY Year 


----/5))  country wise industry and co2-emissionm 
---Country Vs emission - growth trend 



SELECT c.Country,i.industry, Year, AVG(Value) as Emission 
FROM CO2country_industry    -----Code changed need to resend 
LEFT JOIN country_master as c ON c.country_code = CO2country_code
LEFT JOIN industry_master as i ON i.industry_code = co2Industry_code
WHERE c.Country IS NOT NULL
AND i.industry IN ('Agriculture, Forestry and Fishing','Construction',
'Electricity, gas, steam and air conditioning supply','Manufacturing','Mining',
'Transportation and Storage','Food products, beverages and tobacco','Air transport','Chemicals and pharmaceutical products',
'Water transport','Rubber and plastics products')
AND unit IN ('Metric Tons of CO2 Emissions per $1million USD of output')
GROUP BY c.Country, i.industry, Year
ORDER BY Emission desc;


----/ 6) country Vs Forest - indicator : forest area 1000 HA
-----GDP forest area Country

---GDP vs Forest area Updated query---
SELECT * FROM forest_change
select c.country ,forest_change.Year,forest_change.Indicator,AVG(emission) as Forest_change, Sum(g.value) as gdp_value
from forest_change
LEFT JOIN country_master c on c.country_code = fcountry_code 
LEFT JOIN GDP_VALUE g on (g.GCOUNTRY_CODE = fcountry_code AND g.TIME =forest_change.Year)
where forest_change.Indicator In ('Forest area')
AND
c.Country IN (
        'United States', 'China', 'Japan', 'Germany', 'United Kingdom', 
        'India', 'France', 'Brazil', 'Italy', 'Canada', 'Australia', 
        'Spain', 'Netherlands', 'Saudi Arabia')
GROUP BY forest_change.Indicator,c.country,forest_change.Year
ORDER BY gdp_value

---/7) Green house gas emission - world wide
--Graph 7) Region Vs Gas type Emission

SELECT  country  ,gastype, Year,SUM(emission) as emission
FROM greenhouse
WHERE country IS NOT NULL
GROUP BY country ,gastype, Year;

SELECT  country  ,gastype, Year,SUM(emission) as emission
FROM greenhouse
WHERE country IN('Asia','Africa','Americas','Europe','G20','Southern Europe','Advanced Economies','Australia and New Zealand','G7','Southern Asia','Northern America')
GROUP BY country ,gastype, Year;


----8) t test table - spliting countries into 2 HighGDP and Low GDP ----

WITH GDP_Ranking AS (SELECT GCOUNTRY_CODE,
   RANK() OVER (ORDER BY SUM(GDP_VALUE.value) DESC) AS GDP_Rank
FROM
   GDP_VALUE 
   GROUP BY
    GCOUNTRY_CODE)

SELECT C.Country, GDP_VALUE.GCOUNTRY_CODE,  SUM(GDP_VALUE.value) / 10 AS gdp_value,SUM(co2country_industry.[Value]) AS Co2_emission,
CASE
 WHEN GDP_Rank <= 14 THEN 'HighGDP'
  ELSE 'LowGDP'
  END AS GDP_Group
  FROM
 GDP_VALUE
LEFT JOIN country_master C ON C.Country_code = GDP_VALUE.GCOUNTRY_CODE
LEFT JOIN co2country_industry ON co2country_industry.co2country_code = GDP_VALUE.GCOUNTRY_CODE
LEFT JOIN GDP_Ranking ON GDP_VALUE.GCOUNTRY_CODE = GDP_Ranking.GCOUNTRY_CODE
WHERE
    C.Country IS NOT NULL
GROUP BY
    C.Country, GDP_VALUE.GCOUNTRY_CODE, GDP_Rank
ORDER BY
   gdp_value DESC;



--- Bulk insert

BULK INSERT temp_gdp
FROM 'C:\Users\stanley varghese\Desktop\GDP value.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK
);


INSERT INTO Test_GDP (COUNTRY_CODE, INDICATOR, SUBJECT, MEASURE, FREQUENCY, TIME, GDP)
SELECT COUNTRY_CODE, INDICATOR, SUBJECT, MEASURE, FREQUENCY, TIME, GDP
FROM temp_gdp;
DROP TABLE temp_gdp;

--------------------------------------------------------------------
Creating database and tables
 
----1 - Database 
 
CREATE DATABASE "CDMS"
 
----2 - Creating tables No 1 : co2cuntry_industry
 
CREATE TABLE co2cuntry_industry (
 id INTEGER,
 co2Industry_code VARCHAR(6),
 Unit VARCHAR(6),
 co2country_code VARCHAR(6),
 Year INTEGER,
 Value float,
PRIMARY KEY (id),
FOREIGN KEY co2Industry_code REFERENCES industry_master(Industry_code),
FOREIGN KEY  co2country_code REFERENCES country_master(Country_code));

 
----3- Creating tables No 2 : co2world_wide
 
CREATE TABLE co2world_wide (
 id INTEGER,
 Unit VARCHAR(6),
 Date INTEGER,
 Value float,
 Year INTEGER,
PRIMARY KEY (id),
);

 
----4- Creating tables No 3 : country_master
CREATE TABLE country_master (
Country VARCHAR(50),
Country_code VARCHAR(6),
PRIMARY KEY (Country_code)
);

 
 
-----5- Creating tables No 4 : forest_change
 
 
CREATE TABLE forest_change (
 id INTEGER,
 Unit VARCHAR(6),
 Indicator VARCHAR(50),
 fcountry_code VARCHAR(6),
 Year INTEGER,
 emission float,
PRIMARY KEY (id),
FOREIGN KEY  fcountry_code   REFERENCES country_master(Country_code));

 
----6- Creating tables No 5 : GDP_VALUE
 
CREATE TABLE GDP_VALUE (
Id INTEGER,
 GCOUNTRY_CODE VARCHAR(6),
 INDICATOR VARCHAR(10),
 MEASURE VARCHAR(10),
 TIME INTEGER,
 Value float,
PRIMARY KEY (id),
FOREIGN KEY  GCOUNTRY_CODE REFERENCES country_master(Country_code));


-----7- Creating tables No 6 : greenhouse
 
CREATE TABLE greenhouse (
 id INTEGER,
 Country VARCHAR(50),
 gIndustry_code VARCHAR(6),
 gastype VARCHAR(10),
 Unit VARCHAR(50),
 Year INTEGER,
 emission float,
PRIMARY KEY (id),
FOREIGN KEY  gIndustry_code  RFERENCES industry_master(Industry_code));


 
-----8- Creating tables No 7 : industry_master
 
CREATE TABLE industry_master (
    Industry VARCHAR(50)
    Industry_code VARCHAR(6),
PRIMARY KEY (Industry_code)
);

 
-----9- Creating tables No 8 : Surface_change
CREATE TABLE Surface_change (
 id INTEGER,
 Unit VARCHAR(50),
 scountry_code VARCHAR(6),
 Year INTEGER,
 temp_change float,
PRIMARY KEY (id),
FOREIGN KEY  scountry_code REFERENCES country_master(Country_code));


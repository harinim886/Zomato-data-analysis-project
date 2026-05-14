CREATE DATABASE zomato_db;
USE zomato_db;
SELECT * FROM Restaurants;
----- Q1. Build a Country Map Table ------
CREATE TABLE Country_Map (
    CountryCode INT,
    CountryName VARCHAR(100)
);
INSERT INTO Country_Map VALUES
(1,'India'),
(14,'Australia'),
(30,'Brazil'),
(37,'Canada'),
(94,'Indonesia'),
(148,'New Zealand'),
(162,'Philippines'),
(166,'Qatar'),
(184,'Singapore'),
(189,'South Africa'),
(191,'Sri Lanka'),
(208,'Turkey'),
(214,'UAE'),
(215,'United Kingdom'),
(216,'United States');
select * from Country_Map;

----- Q2 Create Calendar Table -----
CREATE TABLE Calendar_Table (
    DateKey DATE,
    Year INT,
    MonthNo INT,
    MonthFullName VARCHAR(20),
    Quarter VARCHAR(2),
    YearMonth VARCHAR(10),
    WeekdayNo INT,
    WeekdayName VARCHAR(20),
    FinancialMonth VARCHAR(5),
    FinancialQuarter VARCHAR(3)
);
----- INSERT ------
INSERT INTO Calendar_Table (DateKey)
SELECT DISTINCT Datekey_Opening
FROM Restaurants
WHERE Datekey_Opening IS NOT NULL;
---- UPDATE CALENDAR COLUMNS -----
SET SQL_SAFE_UPDATES = 0;
UPDATE Calendar_Table
SET 
    Year = YEAR(DateKey),
    MonthNo = MONTH(DateKey),
    MonthFullName = MONTHNAME(DateKey),
    Quarter = CONCAT('Q', QUARTER(DateKey)),
    YearMonth = DATE_FORMAT(DateKey, '%Y-%b'),
    WeekdayNo = DAYOFWEEK(DateKey),
    WeekdayName = DAYNAME(DateKey)
WHERE DateKey IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;
----- FINANCIAL MONTH ----
SET SQL_SAFE_UPDATES = 0;
UPDATE Calendar_Table
SET FinancialMonth = CONCAT('FM',
    CASE 
        WHEN MONTH(DateKey) >= 4 THEN MONTH(DateKey) - 3
        ELSE MONTH(DateKey) + 9
    END
);
SET SQL_SAFE_UPDATES = 1;
----- FINANCIAL QUARTER -----
SET SQL_SAFE_UPDATES = 0;
UPDATE Calendar_Table
SET FinancialQuarter = 
    CASE
        WHEN MONTH(DateKey) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(DateKey) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(DateKey) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END;
select * from Calendar_Table;

------ Q3. Number of Restaurants by City and Country ------
DESC Restaurants;
SELECT 
    c.CountryName,
    r.City,
    COUNT(DISTINCT r.RestaurantID) AS Total_Restaurants
FROM Restaurants r
JOIN Country_Map c 
ON r.CountryCode = c.CountryCode
GROUP BY c.CountryName, r.City
ORDER BY Total_Restaurants DESC;

------ Q4. Restaurants Opening by Year, Quarter, Month -----
SELECT 
    YEAR(Datekey_Opening) AS Year,
    CONCAT('Q', QUARTER(Datekey_Opening)) AS Quarter,
    MONTH(Datekey_Opening) AS MonthNo,
    MONTHNAME(Datekey_Opening) AS Month,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
GROUP BY 
    Year, Quarter, MonthNo, Month
ORDER BY 
    Year, Quarter, MonthNo;
    
----- Q5 Restaurants count by Rating -----
SELECT 
    CASE 
        WHEN Rating IS NULL THEN 'No Rating'
        WHEN Rating = 0 THEN 'Zero Rating'
        ELSE ROUND(Rating,1)
    END AS Rating_Group,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
GROUP BY Rating_Group
ORDER BY Rating_Group DESC;
---- Q6: Bucket Restaurants by Average Price -----
SELECT 'Low' AS Price_Bucket, COUNT(*) AS Total_Restaurants
FROM Restaurants
WHERE Average_Cost_for_two < 1000
UNION ALL
SELECT 'Medium', COUNT(*)
FROM Restaurants
WHERE Average_Cost_for_two BETWEEN 1000 AND 3000
UNION ALL
SELECT 'High', COUNT(*)
FROM Restaurants
WHERE Average_Cost_for_two > 3000;
---- Q7.Percentage of Resturants based on "Has_Table_booking" ------
SELECT 
    Has_Table_booking,
    COUNT(*) AS Restaurant_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Restaurants), 2) AS Percentage
FROM Restaurants
GROUP BY Has_Table_booking;
----- Q8. Percentage of Resturants based on "Has_Online_delivery" ------
SELECT 
    Has_Online_delivery,
    COUNT(*) AS Restaurant_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Restaurants), 2) AS Percentage
FROM Restaurants
GROUP BY Has_Online_delivery;
----- Q9.Develop Charts based on Cusines, City, Ratings ----
---- 1.Restaurants by Cuisines ----
SELECT 
    Cuisines,
    COUNT(*) AS Restaurant_Count
FROM Restaurants
GROUP BY Cuisines
ORDER BY Restaurant_Count DESC;
----- 2.Restaurants by City -----
SELECT 
    City,
    COUNT(*) AS Restaurant_Count
FROM Restaurants
GROUP BY City
ORDER BY Restaurant_Count DESC;
----- 3. Restaurants by Ratings -----
SELECT 
    ROUND(Rating,1) AS Rating,
    COUNT(*) AS Restaurant_Count
FROM Restaurants
GROUP BY ROUND(Rating,1)
ORDER BY Rating DESC;
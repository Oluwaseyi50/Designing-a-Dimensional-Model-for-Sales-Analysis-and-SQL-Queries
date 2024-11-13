create database DA_flora22;
use DA_flora22;

/* Verify Data Types*/
DESCRIBE customer;
DESCRIBE Vehicle;
DESCRIBE Parts;
DESCRIBE Job;
DESCRIBE Invoice;

/*Check for Missing Values*/
-- For Customers
SELECT * FROM Customers WHERE Name IS NULL OR Address IS NULL OR Phone IS NULL;

-- For Vehicles
SELECT * FROM Vehicles WHERE VIN IS NULL OR Make IS NULL OR Model IS NULL;

-- For Parts
SELECT * FROM Parts WHERE PartNumber IS NULL OR PartName IS NULL;

-- For Jobs
SELECT * FROM Jobs WHERE VIN IS NULL OR Description IS NULL;

-- For Invoices
SELECT * FROM Invoices WHERE InvoiceDate IS NULL OR Subtotal IS NULL OR Total IS NULL;

/* Check for Duplicate Records*/
-- For Customers
SELECT Name, Address, Phone, COUNT(*) 
FROM Customers 
GROUP BY Name, Address, Phone 
HAVING COUNT(*) > 1;

-- For Vehicles
SELECT VIN, COUNT(*) 
FROM Vehicles 
GROUP BY VIN 
HAVING COUNT(*) > 1;

-- For Parts
SELECT PartID, PartNumber, COUNT(*) 
FROM Parts 
GROUP BY PartID, PartNumber 
HAVING COUNT(*) > 1;


/*Change Column Data Types*/

---- Modify 'customer' table
ALTER TABLE Customer
MODIFY Phone VARCHAR(15);

-- Modify 'Vehicle' table
ALTER TABLE Vehicle
MODIFY VIN VARCHAR(20),
MODIFY Mileage INT;

-- Modify 'Parts' table
ALTER TABLE Parts
MODIFY Quantity INT,
MODIFY UnitPrice DECIMAL(10, 2),
MODIFY Amount DECIMAL(10, 2);

-- Modify 'Job' table
ALTER TABLE Job
MODIFY Hours DECIMAL(5, 2),
MODIFY Rate DECIMAL(10, 2),
MODIFY Amount DECIMAL(10, 2);

-- Modify 'Invoice' table
ALTER TABLE Invoice
MODIFY InvoiceDate DATE,
MODIFY Subtotal DECIMAL(10, 2),
MODIFY SalesTaxRate DECIMAL(5, 2),
MODIFY SalesTax DECIMAL(10, 2),
MODIFY TotalLabour DECIMAL(10, 2),
MODIFY TotalParts DECIMAL(10, 2),
MODIFY Total DECIMAL(10, 2);

/* Add Index*/
ALTER TABLE Invoice ADD INDEX (InvoiceID);
ALTER TABLE Parts ADD INDEX (PartID);
ALTER TABLE Job ADD INDEX (JobID);
-- For the Customer table
ALTER TABLE Customer
ADD COLUMN CustomerID INT PRIMARY KEY AUTO_INCREMENT;
ALTER TABLE Customer ADD INDEX (CustomerID);

/*Verify changes*/
DESCRIBE Customers;
DESCRIBE Vehicles;
DESCRIBE Parts;
DESCRIBE Jobs;
DESCRIBE Invoices;
DESCRIBE FactSales;


/*Create the FactSales Table*/
CREATE TABLE FactSales (
    FactID INT PRIMARY KEY AUTO_INCREMENT,
    InvoiceID INT,
    PartID INT,
    JobID INT,
    CustomerID INT,
    VIN VARCHAR(20),
    InvoiceDate DATE,
    Subtotal DECIMAL(10, 2),
    SalesTaxRate DECIMAL(5, 2),
    SalesTax DECIMAL(10, 2),
    TotalLabour DECIMAL(10, 2),
    TotalParts DECIMAL(10, 2),
    Total DECIMAL(10, 2),
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID),
    FOREIGN KEY (PartID) REFERENCES Parts(PartID),
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

INSERT INTO FactSales 
(InvoiceID, PartID, JobID, CustomerID, VIN, InvoiceDate, Subtotal, SalesTaxRate, SalesTax, TotalLabour, TotalParts, Total) 
VALUES 
(12345, 1, 2, 1, 'CVS123456789123-115Z', '2023-09-10', 969.87, 13, 207.33, 625, 969.87, 1802.2),
(12346, 2, 4, 2, 'TYS678901234567-876Z', '2023-09-15', 325, 13, 42.25, 325, 0, 367.25),
(12347, 3, 6, 3, 'HCS345678901234-123X', '2023-09-20', 200, 13, 26, 200, 0, 226),
(12348, 4, 8, 4, 'FES234567890123-456Y', '2023-09-25', 300, 13, 39, 300, 0, 339),
(12349, 5, 10, 5, 'CMS456789012345-789Z', '2023-09-30', 440, 13, 57.2, 440, 0, 497.2);


------ Customer Analysis
/*Identify the top 5 customers who have spent the most on vehicle repairs and parts:*/


SELECT c.CustomerID, c.Name, SUM(fs.Total) AS TotalSpent
FROM Customer c
JOIN FactSales fs ON c.CustomerID = fs.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC
LIMIT 5;


/*Determine the average spending of customers on repairs and parts:*/


SELECT AVG(TotalSpent) AS AvgSpending
FROM (
    SELECT c.CustomerID, SUM(fs.Total) AS TotalSpent
    FROM Customer c
    JOIN FactSales fs ON c.CustomerID = fs.CustomerID
    GROUP BY c.CustomerID
) AS Subquery;


/*Analyze the frequency of customer visits and identify any patterns:*/



SELECT c.CustomerID, c.Name, COUNT(DISTINCT fs.InvoiceID) AS NumberOfVisits
FROM Customer c
JOIN FactSales fs ON c.CustomerID = fs.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY NumberOfVisits DESC;


------- Vehicle Analysis
/*Calculate the average mileage of vehicles serviced:*/



SELECT AVG(v.Mileage) AS AvgMileage
FROM Vehicle v
JOIN Job j ON v.VIN = j.VIN;

/*Identify the most common vehicle makes and models brought in for service:*/



SELECT v.Make, v.Model, COUNT(*) AS Frequency
FROM Vehicle v
JOIN Job j ON v.VIN = j.VIN
GROUP BY v.Make, v.Model
ORDER BY Frequency DESC;


/*Analyze the distribution of vehicle ages and identify any trends in service requirements based on vehicle age:*/



SELECT YEAR(CURDATE()) - v.Year AS VehicleAge, COUNT(*) AS Frequency
FROM Vehicle v
JOIN Job j ON v.VIN = j.VIN
GROUP BY VehicleAge
ORDER BY VehicleAge;


-------- Job Analysis
/*Determine the most common types of jobs performed and their frequency:*/


SELECT j.Description, COUNT(*) AS Frequency
FROM Job j
GROUP BY j.Description
ORDER BY Frequency DESC;


/*Calculate the total revenue generated from each type of job:*/


SELECT j.Description, SUM(j.Amount) AS TotalRevenue
FROM Job j
GROUP BY j.Description
ORDER BY TotalRevenue DESC;


/*Identify the jobs with the highest and lowest average costs:*/



SELECT j.Description, AVG(j.Amount) AS AvgCost
FROM Job j
GROUP BY j.Description
ORDER BY AvgCost DESC; -- For highest average cost

SELECT j.Description, AVG(j.Amount) AS AvgCost
FROM Job j
GROUP BY j.Description
ORDER BY AvgCost ASC; -- For lowest average cost

------ Parts usuage Analysis
/*List the top 5 most frequently used parts and their total usage:*/



SELECT p.PartName, SUM(p.Quantity) AS TotalUsage
FROM Parts p
GROUP BY p.PartName
ORDER BY TotalUsage DESC
LIMIT 5;


/*Calculate the average cost of parts used in repairs:*/



SELECT AVG(p.UnitPrice) AS AvgPartCost
FROM Parts p;


/*Determine the total revenue generated from parts sales:*/


SELECT SUM(p.Amount) AS TotalRevenue
FROM Parts p;


------- Financial Analysis
/*Calculate the total revenue generated from labor and parts for each month*/


SELECT DATE_FORMAT(i.InvoiceDate, '%Y-%m') AS Month, 
       SUM(fs.TotalLabour) AS TotalLabour, 
       SUM(fs.TotalParts) AS TotalParts, 
       SUM(fs.TotalLabour + fs.TotalParts) AS TotalRevenue
FROM FactSales fs
JOIN Invoice i ON fs.InvoiceID = i.InvoiceID
GROUP BY Month
ORDER BY Month;


/*Determine the overall profitability of the repair shop:*/


SELECT SUM(i.Subtotal) AS TotalRevenue, 
       SUM(i.SalesTax) AS TotalSalesTax, 
       SUM(i.Total) - SUM(i.Subtotal) - SUM(i.SalesTax) AS TotalProfit
FROM Invoice i;


/*Analyze the impact of sales tax on the total revenue:*/


SELECT 
    SUM(i.SalesTax) AS TotalSalesTax,
    SUM(i.Subtotal) AS TotalBeforeTax,
    SUM(i.Total) AS TotalAfterTax,
    (SUM(i.SalesTax) / SUM(i.Total)) * 100 AS SalesTaxPercentage
FROM Invoice i;




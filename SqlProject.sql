-----SQL PROJECT 
----SE VCITUVA ZA 51 SEKUNDA POKAZUVA NEKOJ WARRNING NO GI VNESUVA PODATOCITE CELOSNO I KAKO STO SE BARA

--- Insertot vo dbo.salary ne e dobar, vrednosti za bonusamount i overtime amount ima vo sekoj mesec namesto samo vo neparni t.e. parni soodvetno.

---CREATING DATABES
CREATE DATABASE SqlProject_TrpoStojkoski
GO

USE SqlProject_TrpoStojkoski
GO

----- CREATING TABLES
--- SENIORITYLEVEL
CREATE TABLE SeniorityLevel
(
	ID int IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(100) NOT NULL
	CONSTRAINT PK_SeniorityLevel PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--- LOCATION
CREATE TABLE [Location]
(
	ID int IDENTITY(1,1) NOT NULL,
	CountryName nvarchar(100) NULL,
	Continent nvarchar(100) NULL,
	Region nvarchar(100) NULL,
	CONSTRAINT PK_Location PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--- DEPARTMENT
CREATE TABLE Department
(
	ID int IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(100) NOT NULL,
	CONSTRAINT PK_Department PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--- EMPLOYEE
CREATE TABLE Employee
(
	ID int IDENTITY(1,1) NOT NULL,
	FirstName nvarchar(100) NOT NULL,
	LastName nvarchar(100) NOT NULL,
	LocationID int NOT NULL,
	SeniorityLevelID int NOT NULL,
	DepartmentID int NOT NULL,
	CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (ID ASC)
)
GO

--- SALARY
CREATE TABLE Salary
(	
	ID int IDENTITY(1,1) NOT NULL,
	EmployeeID int NOT NULL,
	[Month] smallint NOT NULL,
	[Year] smallint NOT NULL,
	GrossAmount decimal(18,2) NOT NULL,
	NetAmount decimal(18,2) NOT NULL,
	RegularWorkAmount decimal(18,2) NOT NULL,
	BonusAmount decimal(18,2) NOT NULL,
	OvertimeAmount decimal(18,2) NOT NULL,
	VacationDays smallint NOT NULL,
	SickLeaveDays smallint NOT NULL,
	CONSTRAINT PK_Salary PRIMARY KEY CLUSTERED (ID ASC)
)
GO

----- INSERT INTO
--- SeniorityLevel
INSERT INTO SeniorityLevel([Name])
Values
	('Junior'),
	('[Intermediate]'),
	('Senior'),
	('[Lead]'),
	('Project Manager'),
	('Division Manager'),
	('Office Manager'),
	('CEO'),
	('CTO'),
	('CIO');
GO

--- Location
INSERT INTO [Location](CountryName,Continent,Region)
SELECT
	CountryName,Continent,Region
FROM
	WideWorldImporters.[Application].Countries
GO

--- DEPARTMENT
INSERT INTO Department([Name])
VALUES
	('Personal Banking & Operations'),
	('Digital Banking Department'),
	('Retail Banking & Marketing Department'),
	('Wealth Management & Third Party Products'),
	('International Banking Division & DFB'),
	('Treasury'),
	('Information Technology'),
	('Corporate Communications'),
	('Suppoert Services & Branch Expansion'),
	('Humman Resources');
GO

--- EMPLOYEE FIRST NAME,LAST NAME, LOCATION,SENIORITYLEVEL, DEPARTMENT
INSERT INTO Employee (FirstName, LastName, LocationID, SeniorityLevelID, DepartmentID)
SELECT 
    SUBSTRING(FullName, 0, CHARINDEX(' ', FullName)), 
    SUBSTRING(FullName, CHARINDEX(' ', FullName) + 1, LEN(FullName)),
    ((ROW_NUMBER() OVER (ORDER BY PersonID) - 1) / ((SELECT COUNT(*) FROM WideWorldImporters.Application.People) / 190)) + 1,
    ((ROW_NUMBER() OVER (ORDER BY PersonID) - 1) / ((SELECT COUNT(*) FROM WideWorldImporters.Application.People) / 10)) + 1,
    ((ROW_NUMBER() OVER (ORDER BY PersonID) - 1) / ((SELECT COUNT(*) FROM WideWorldImporters.Application.People) / 10)) + 1
FROM WideWorldImporters.Application.People;
	
----- SALARY
--- DATA FOR THE PAST 20 YEARS, GROSS AMOUNT, NET AMOUNT, REGULAR WORK AMOUNT, BONUS AMOUNT, OVER TIME AMOUNT, VACATION DAYS
-- Get all the employees from the Employee table
DECLARE @start_month INT = 1
DECLARE @start_year INT = 2001
DECLARE @end_month INT = 12
DECLARE @end_year INT = 2020
DECLARE @employee_count INT
DECLARE @current_month INT = @start_month
DECLARE @current_year INT = @start_year
DECLARE @gross_amount FLOAT
DECLARE @net_amount FLOAT
DECLARE @regular_work_amount FLOAT
DECLARE @bonus_amount FLOAT
DECLARE @overtime_amount FLOAT
DECLARE @vacation_days INT = 10
DECLARE @sick_leave_days INT = 0

SELECT @employee_count = COUNT(*)
FROM Employee

WHILE (@current_year < 2021)
BEGIN
	WHILE (@current_month <= @end_month)
	BEGIN
		DECLARE @employee_id INT = 1

		WHILE (@employee_id <= @employee_count)
			BEGIN
			  SET @gross_amount = RAND(CHECKSUM(NEWID())) * (60000 - 30000) + 30000
			  SET @net_amount = @gross_amount * 0.9
			  SET @regular_work_amount = @net_amount * 0.8

			  IF (@current_month % 2 = 1)
				SET @bonus_amount = @net_amount - @regular_work_amount
			  ELSE
				SET @overtime_amount = @net_amount - @regular_work_amount

			  INSERT INTO Salary (EmployeeID, Month, Year, GrossAmount, NetAmount, RegularWorkAmount, BonusAmount, OvertimeAmount, VacationDays, SickLeaveDays)
			  VALUES (@employee_id, @current_month, @current_year, @gross_amount, @net_amount, @regular_work_amount, @bonus_amount, @overtime_amount,
					  CASE WHEN @current_month = 7 THEN @vacation_days ELSE 0 END,
					  CASE WHEN @current_month = 12 THEN @vacation_days ELSE 0 END)

			  SET @employee_id = @employee_id + 1
		END

		SET @current_month = @current_month + 1
		IF (@current_month = 13)
			BEGIN
			  SET @current_month = 1
			  SET @current_year = @current_year + 1
		END

		IF(@current_year = 2021)
			BEGIN	
			SET @current_month = 13
			BREAK;
		END
	END
END



--- UPDATE VACATION DAYS AND SICK LEAVE DAYS
UPDATE Salary SET VacationDays = VacationDays + (EmployeeID % 2)
	WHERE 
		(EmployeeID + MONTH + YEAR)% 5 = 1
GO

UPDATE Salary set SickLeaveDays = EmployeeID % 8, VacationDays = VacationDays + (EmployeeID % 3)
	WHERE
		(EmployeeID + MONTH + YEAR)% 5 = 2
GO

SELECT * FROM Salary
SELECT * FROM Employee
SELECT * FROM SeniorityLevel
SELECt * FROM Department
SELECT * FROM [Location]

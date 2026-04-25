-- Create database
CREATE DATABASE HR_Analytics_DW;
GO

USE HR_Analytics_DW;
GO

-- Dimension tables
CREATE TABLE dimEmployee (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender NVARCHAR(10),
    Age INT,
    MaritalStatus NVARCHAR(20),
    EducationField NVARCHAR(50)
);

CREATE TABLE dimDepartment (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) UNIQUE
);

CREATE TABLE dimJobRole (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    JobRoleName NVARCHAR(50) UNIQUE
);

-- Fact table
CREATE TABLE factAttrition (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT FOREIGN KEY REFERENCES dimEmployee(EmployeeID),
    DepartmentID INT FOREIGN KEY REFERENCES dimDepartment(DepartmentID),
    JobRoleID INT FOREIGN KEY REFERENCES dimJobRole(JobRoleID),
    AttritionFlag BIT,
    MonthlyIncome DECIMAL(10,2),
    YearsAtCompany INT,
    PerformanceRating INT,
    DistanceFromHome INT
);
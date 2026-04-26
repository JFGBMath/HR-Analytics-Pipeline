-- ============================================
-- Script 02: Populate Star Schema from Staging
-- Database: HR_Analytics_DW
-- ============================================

USE HR_Analytics_DW;
GO

-- 1. Department Dimension
INSERT INTO dbo.dimDepartment (DepartmentName)
SELECT DISTINCT Department
FROM dbo.HR_Attrition_Fact
WHERE Department IS NOT NULL
  AND Department NOT IN (SELECT DepartmentName FROM dbo.dimDepartment);

-- 2. JobRole Dimension
INSERT INTO dbo.dimJobRole (JobRoleName)
SELECT DISTINCT JobRole
FROM dbo.HR_Attrition_Fact
WHERE JobRole IS NOT NULL
  AND JobRole NOT IN (SELECT JobRoleName FROM dbo.dimJobRole);

-- 3. Employee Dimension
-- Note: Source CSV does not contain real names, using placeholders
INSERT INTO dbo.dimEmployee (EmployeeID, FirstName, LastName, Gender, Age, MaritalStatus, EducationField)
SELECT 
    EmployeeID,
    'Employee'                    AS FirstName,
    CAST(EmployeeID AS NVARCHAR)  AS LastName,
    Gender,
    Age,
    MaritalStatus,
    EducationField
FROM dbo.HR_Attrition_Fact
WHERE EmployeeID IS NOT NULL
  AND EmployeeID NOT IN (SELECT EmployeeID FROM dbo.dimEmployee);

-- 4. Fact Table
INSERT INTO dbo.factAttrition (
    EmployeeID, DepartmentID, JobRoleID,
    AttritionFlag, MonthlyIncome, YearsAtCompany,
    PerformanceRating, DistanceFromHome
)
SELECT 
    s.EmployeeID,
    d.DepartmentID,
    j.JobRoleID,
    CASE WHEN s.Attrition = 'Yes' THEN 1 ELSE 0 END AS AttritionFlag,
    s.MonthlyIncome,
    s.YearsAtCompany,
    s.PerformanceRating,
    s.DistanceFromHome
FROM dbo.HR_Attrition_Fact s
JOIN dbo.dimDepartment d ON s.Department = d.DepartmentName
JOIN dbo.dimJobRole    j ON s.JobRole    = j.JobRoleName
WHERE s.EmployeeID IS NOT NULL
  AND s.EmployeeID NOT IN (SELECT EmployeeID FROM dbo.factAttrition);

-- Quick row count verification
SELECT 'dimDepartment'  AS TableName, COUNT(*) AS [RowCount] FROM dbo.dimDepartment
UNION ALL SELECT 'dimJobRole',        COUNT(*) FROM dbo.dimJobRole
UNION ALL SELECT 'dimEmployee',       COUNT(*) FROM dbo.dimEmployee
UNION ALL SELECT 'factAttrition',     COUNT(*) FROM dbo.factAttrition;
-- ============================================
-- Script 03: Advanced SQL Queries
-- Techniques: CTEs, Window Functions, NTILE,
--             ROW_NUMBER, LAG, RANK
-- Database: HR_Analytics_DW
-- ============================================

USE HR_Analytics_DW;
GO

-- -----------------------------------------------
-- Query 1: Attrition rate by department
-- Techniques: CTE, RANK() window function
-- -----------------------------------------------
WITH DeptStats AS (
    SELECT 
        d.DepartmentName,
        COUNT(*)                                         AS TotalEmployees,
        SUM(CAST(f.AttritionFlag AS INT))                AS AttritionCount,
        AVG(CAST(f.MonthlyIncome    AS DECIMAL(10,2)))   AS AvgMonthlyIncome,
        AVG(CAST(f.YearsAtCompany   AS DECIMAL(10,2)))   AS AvgTenure,
        AVG(CAST(f.PerformanceRating AS DECIMAL(10,2)))  AS AvgPerformanceRating
    FROM dbo.factAttrition f
    JOIN dbo.dimDepartment d ON f.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentName
)
SELECT 
    DepartmentName,
    TotalEmployees,
    AttritionCount,
    TotalEmployees - AttritionCount                                  AS ActiveEmployees,
    CAST(AttritionCount * 100.0 / TotalEmployees AS DECIMAL(5,2))   AS AttritionRate_Pct,
    AvgMonthlyIncome,
    AvgTenure,
    AvgPerformanceRating,
    RANK() OVER (ORDER BY AttritionCount * 100.0 / TotalEmployees DESC) AS AttritionRank
FROM DeptStats
ORDER BY AttritionRate_Pct DESC;
GO

-- -----------------------------------------------
-- Query 2: Salary analysis within each Job Role
-- Techniques: ROW_NUMBER, NTILE, LAG, AVG OVER
-- -----------------------------------------------
SELECT 
    e.EmployeeID,
    d.DepartmentName,
    j.JobRoleName,
    f.MonthlyIncome,
    f.YearsAtCompany,
    f.AttritionFlag,
    -- Salary rank within the same role (1 = highest paid)
    ROW_NUMBER() OVER (PARTITION BY f.JobRoleID ORDER BY f.MonthlyIncome DESC)       AS SalaryRankInRole,
    -- Salary quartile within the same role (1 = lowest, 4 = highest)
    NTILE(4)     OVER (PARTITION BY f.JobRoleID ORDER BY f.MonthlyIncome)            AS SalaryQuartile,
    -- Difference vs average salary for the same role
    f.MonthlyIncome - AVG(f.MonthlyIncome) OVER (PARTITION BY f.JobRoleID)          AS DiffFromRoleAvg,
    -- Previous employee salary in the same role (ordered by income)
    LAG(f.MonthlyIncome) OVER (PARTITION BY f.JobRoleID ORDER BY f.MonthlyIncome)   AS PrevSalaryInRole
FROM dbo.factAttrition f
JOIN dbo.dimEmployee   e ON f.EmployeeID   = e.EmployeeID
JOIN dbo.dimDepartment d ON f.DepartmentID = d.DepartmentID
JOIN dbo.dimJobRole    j ON f.JobRoleID    = j.JobRoleID
ORDER BY j.JobRoleName, f.MonthlyIncome DESC;
GO

-- -----------------------------------------------
-- Query 3: Attrition risk profile
-- Techniques: Nested CTEs, NTILE, CASE
-- -----------------------------------------------
WITH RiskProfile AS (
    SELECT 
        e.EmployeeID,
        d.DepartmentName,
        j.JobRoleName,
        e.Age,
        e.Gender,
        e.MaritalStatus,
        f.MonthlyIncome,
        f.YearsAtCompany,
        f.PerformanceRating,
        f.DistanceFromHome,
        f.AttritionFlag,
        NTILE(4) OVER (ORDER BY f.MonthlyIncome)   AS SalaryQuartile,
        NTILE(4) OVER (ORDER BY f.YearsAtCompany)  AS TenureQuartile
    FROM dbo.factAttrition f
    JOIN dbo.dimEmployee   e ON f.EmployeeID   = e.EmployeeID
    JOIN dbo.dimDepartment d ON f.DepartmentID = d.DepartmentID
    JOIN dbo.dimJobRole    j ON f.JobRoleID    = j.JobRoleID
),
WithRiskLevel AS (
    SELECT *,
        CASE 
            WHEN SalaryQuartile = 1 AND TenureQuartile = 1 THEN 'High'
            WHEN SalaryQuartile <= 2 AND TenureQuartile <= 2 THEN 'Medium'
            ELSE 'Low'
        END AS RiskLevel
    FROM RiskProfile
)
SELECT *
FROM WithRiskLevel
ORDER BY RiskLevel, MonthlyIncome ASC;
GO
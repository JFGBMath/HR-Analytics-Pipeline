-- ============================================
-- Script 04: Stored Procedures
-- These will be used directly as SSRS datasets
-- Database: HR_Analytics_DW
-- ============================================

USE HR_Analytics_DW;
GO

-- -----------------------------------------------
-- SP 1: Attrition summary by department
-- Parameters: @DepartmentName (optional filter)
-- -----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_AttritionByDepartment
    @DepartmentName NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
        WHERE @DepartmentName IS NULL
           OR d.DepartmentName = @DepartmentName
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
        AvgPerformanceRating
    FROM DeptStats
    ORDER BY AttritionRate_Pct DESC;
END;
GO

-- -----------------------------------------------
-- SP 2: Employee-level attrition risk list
-- Parameters: @DepartmentName, @RiskLevel (both optional)
-- This SP feeds the main SSRS paginated report
-- -----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_EmployeesAtRisk
    @DepartmentName NVARCHAR(50) = NULL,
    @RiskLevel      NVARCHAR(10) = NULL    -- 'High', 'Medium', 'Low'
AS
BEGIN
    SET NOCOUNT ON;

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
        WHERE @DepartmentName IS NULL
           OR d.DepartmentName = @DepartmentName
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
    WHERE @RiskLevel IS NULL OR RiskLevel = @RiskLevel
    ORDER BY RiskLevel, MonthlyIncome ASC;
END;
GO

-- -----------------------------------------------
-- Quick tests
-- -----------------------------------------------
EXEC dbo.sp_AttritionByDepartment;
EXEC dbo.sp_AttritionByDepartment @DepartmentName = 'Sales';
EXEC dbo.sp_EmployeesAtRisk;
EXEC dbo.sp_EmployeesAtRisk @RiskLevel = 'High';
EXEC dbo.sp_EmployeesAtRisk @DepartmentName = 'Sales', @RiskLevel = 'High';
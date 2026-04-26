-- ============================================
-- Script 03: Performance Indexes
-- Database: HR_Analytics_DW
-- ============================================

USE HR_Analytics_DW;
GO

-- Most frequent join column in reports
CREATE NONCLUSTERED INDEX IX_factAttrition_DepartmentID
    ON dbo.factAttrition (DepartmentID)
    INCLUDE (AttritionFlag, MonthlyIncome, YearsAtCompany);

-- Used in JobRole-level analysis
CREATE NONCLUSTERED INDEX IX_factAttrition_JobRoleID
    ON dbo.factAttrition (JobRoleID)
    INCLUDE (AttritionFlag, PerformanceRating);

-- Filtered queries on attrition status
CREATE NONCLUSTERED INDEX IX_factAttrition_AttritionFlag
    ON dbo.factAttrition (AttritionFlag)
    INCLUDE (DepartmentID, MonthlyIncome);
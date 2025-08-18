-- HEALTHCARE DATA EXPLORATION


-- Dataset Overview : Total number of ED visits, ambulatory visits,discharges,unique patients, providers, and visits
SELECT 
    'Dataset Overview' AS Summary,
    (SELECT COUNT(*) FROM EDVisits) AS Total_ED_Visits,
    (SELECT COUNT(*) FROM AmbulatoryVisits) AS Total_Ambulatory_Visits,
    (SELECT COUNT(*) FROM Discharges) AS Total_Discharges,     
    (SELECT COUNT(DISTINCT ProviderID) FROM Providers) AS Total_Providers,
    (SELECT COUNT(DISTINCT PatientMRN) FROM Patients) AS Total_Patients;
------------------------------------------------------------------------------------------
-- Data Integrity Check: Orphaned records between tables

SELECT
    'ED Visits without Patient Records' AS Integrity_Check,
    COUNT(*) AS Orphaned_Count
FROM EDVisits e
LEFT JOIN Patients p ON e.PatientMRN = p.PatientMRN
WHERE p.PatientMRN IS NULL

UNION ALL

SELECT
    'Ambulatory Visits without Patient Records' AS Integrity_Check,
    COUNT(*) AS Orphaned_Count
FROM AmbulatoryVisits av
LEFT JOIN Patients p ON av.PatientMRN = p.PatientMRN
WHERE p.PatientMRN IS NULL

UNION ALL

SELECT
    'Ambulatory Visits without Provider Records' AS Integrity_Check,
    COUNT(*) AS Orphaned_Count
FROM AmbulatoryVisits av
LEFT JOIN Providers pr ON av.ProviderID = pr.ProviderID
WHERE pr.ProviderID IS NULL

UNION ALL

SELECT
    'Readmissions without Discharge Records' AS Integrity_Check,
    COUNT(*) AS Orphaned_Count
FROM ReadmissionRegistry r
LEFT JOIN Discharges d ON r.AdmissionID = d.AdmissionID
WHERE d.AdmissionID IS NULL;

---------------------------------------------------------------------------------------------------------
-- Data Completeness Assessment: Missing values in critical fields

WITH DataCompleteness AS (
    SELECT
        'Patients' AS TableName,
        COUNT(*) AS TotalRecords,
        COUNT(PatientMRN) AS PatientMRN_Complete,
        COUNT(DateOfBirth) AS Date_Complete,
        NULL AS VisitDate_Complete,
        NULL AS AdmissionDate_Complete,
        NULL AS DateofVisit_Complete
    FROM Patients

    UNION ALL

    SELECT
        'EDVisits' AS TableName,
        COUNT(*) AS TotalRecords,
        COUNT(PatientMRN) AS PatientMRN_Complete,
        NULL AS Date_Complete,
        COUNT(VisitDate) AS VisitDate_Complete,
        NULL AS AdmissionDate_Complete,
        NULL AS DateofVisit_Complete
    FROM EDVisits

    UNION ALL

    SELECT
        'Discharges' AS TableName,
        COUNT(*) AS TotalRecords,
        COUNT(PatientID) AS PatientMRN_Complete,
        NULL AS Date_Complete,
        NULL AS VisitDate_Complete,
        COUNT(AdmissionDate) AS AdmissionDate_Complete,
        NULL AS DateofVisit_Complete
    FROM Discharges

    UNION ALL

    SELECT
        'AmbulatoryVisits' AS TableName,
        COUNT(*) AS TotalRecords,
        COUNT(PatientMRN) AS PatientMRN_Complete,
        NULL AS Date_Complete,
        NULL AS VisitDate_Complete,
        NULL AS AdmissionDate_Complete,
        COUNT(DateofVisit) AS DateofVisit_Complete
    FROM AmbulatoryVisits
)

SELECT
    TableName,
    TotalRecords,
    CAST(100.0 * PatientMRN_Complete / TotalRecords AS DECIMAL(10,2)) AS PatientID_Completeness_Pct,
    CAST(100.0 * (TotalRecords - PatientMRN_Complete) / TotalRecords AS DECIMAL(10,2)) AS PatientID_Missing_Pct,

    
    CASE
        WHEN TableName = 'Patients' THEN CAST(100.0 * Date_Complete / TotalRecords AS DECIMAL(10,2))
        WHEN TableName = 'EDVisits' THEN CAST(100.0 * VisitDate_Complete / TotalRecords AS DECIMAL(10,2))
        WHEN TableName = 'Discharges' THEN CAST(100.0 * AdmissionDate_Complete / TotalRecords AS DECIMAL(10,2))
        WHEN TableName = 'AmbulatoryVisits' THEN CAST(100.0 * DateofVisit_Complete / TotalRecords AS DECIMAL(10,2))
    END AS Key_Date_Completeness_Pct

FROM DataCompleteness;

----------------------------------------------------------------------------------------------

-- Age Distribution Analysis: Patient age groups and utilization patterns

WITH PatientAges AS (
    SELECT
        p.PatientMRN,
        p.Gender,
        p.Race,
        p.Language,
        DATEDIFF(year, p.DateOfBirth, GETDATE()) AS Current_Age,
        CASE
            WHEN DATEDIFF(year, p.DateOfBirth, GETDATE()) < 18 THEN 'Pediatric (0-17)'
            WHEN DATEDIFF(year, p.DateOfBirth, GETDATE()) BETWEEN 18 AND 34 THEN 'Young Adult (18-34)'
            WHEN DATEDIFF(year, p.DateOfBirth, GETDATE()) BETWEEN 35 AND 49 THEN 'Adult (35-49)'
            WHEN DATEDIFF(year, p.DateOfBirth, GETDATE()) BETWEEN 50 AND 64 THEN 'Middle Age (50-64)'
            WHEN DATEDIFF(year, p.DateOfBirth, GETDATE()) BETWEEN 65 AND 79 THEN 'Senior (65-79)'
            ELSE '6. Elderly (80+)'
        END AS AgeGroup
    FROM Patients p
    WHERE p.DateOfBirth IS NOT NULL
)
SELECT
    pa.AgeGroup,
    COUNT(DISTINCT pa.PatientMRN) AS Unique_Patients,
    COUNT(e.EDvisitID) AS Total_ED_Visits,
    COUNT(av.VisitID) AS Total_Ambulatory_Visits,
    ROUND(AVG(CAST(pa.Current_Age AS FLOAT)), 1) AS Average_Age,
    CAST(COUNT(e.EDvisitID) * 1.0 / NULLIF(COUNT(DISTINCT pa.PatientMRN), 0) AS DECIMAL(10,2)) AS ED_Visits_Per_Patient,
    CAST(COUNT(av.VisitID) * 1.0 / NULLIF(COUNT(DISTINCT pa.PatientMRN), 0) AS DECIMAL(10,2)) AS Ambulatory_Visits_Per_Patient,
    CAST(100.0 * COUNT(DISTINCT pa.PatientMRN) / SUM(COUNT(DISTINCT pa.PatientMRN)) OVER()AS DECIMAL(10,2)) AS Patient_Distribution_Pct
FROM PatientAges pa
LEFT JOIN EDVisits e ON pa.PatientMRN = e.PatientMRN
LEFT JOIN AmbulatoryVisits av ON pa.PatientMRN = av.PatientMRN
GROUP BY pa.AgeGroup
ORDER BY pa.AgeGroup;
----------------------------------------------------------------------------------------------

-- Demographic Analysis: Gender, race, language patterns and care disparities

SELECT
    p.Gender,
    p.Race,
    p.Language,
    COUNT(DISTINCT p.PatientMRN) AS Patient_Count,
    COUNT(e.EDvisitID) AS Total_ED_Visits,
    COUNT(av.VisitID) AS Total_Ambulatory_Visits,
    CAST(AVG(CASE WHEN e.Acuity IN ('1', '2') THEN 1.0 ELSE 0.0 END) * 100 AS DECIMAL(10,2 ) )AS High_Acuity_ED_Percentage,
    CAST(AVG(CASE WHEN e.EDDisposition = 'Admitted' THEN 1.0 ELSE 0.0 END) * 100AS DECIMAL(10,2)) AS ED_Admission_Rate,
    CAST(COUNT(e.EDvisitID) * 1.0 / NULLIF(COUNT(DISTINCT p.PatientMRN), 0) AS DECIMAL(10,2)) AS Avg_ED_Visits_Per_Patient,
    CAST(COUNT(av.VisitID) * 1.0 / NULLIF(COUNT(DISTINCT p.PatientMRN), 0) AS DECIMAL(10,2)) AS Avg_Ambulatory_Visits_Per_Patient,
    CAST(100.0 * COUNT(DISTINCT p.PatientMRN) / SUM(COUNT(DISTINCT p.PatientMRN)) OVER()AS DECIMAL(10,2)) AS Population_Percentage
FROM Patients p
LEFT JOIN EDVisits e ON p.PatientMRN = e.PatientMRN
LEFT JOIN AmbulatoryVisits av ON p.PatientMRN = av.PatientMRN
WHERE p.Gender IS NOT NULL AND p.Race IS NOT NULL
GROUP BY p.Gender, p.Race, p.Language
HAVING COUNT(DISTINCT p.PatientMRN) >= 10
ORDER BY Patient_Count DESC;


---------------------------------------------------------------------------------------------

-- High Utilizer Identification: Multiple ED visits and patient characteristics

WITH PatientUtilization AS (
    SELECT
        p.PatientMRN,
        COUNT(e.EDvisitID) AS Total_ED_Visits,
        COUNT(av.VisitID) AS Total_Ambulatory_Visits,
        COUNT(CASE WHEN e.VisitDate >= DATEADD(day, -30, GETDATE()) THEN e.EDvisitID END) AS ED_Visits_30_Days,
        COUNT(CASE WHEN e.VisitDate >= DATEADD(day, -90, GETDATE()) THEN e.EDvisitID END) AS ED_Visits_90_Days,
        MIN(e.VisitDate) AS First_ED_Visit,
        MAX(e.VisitDate) AS Last_ED_Visit
    FROM Patients p
    LEFT JOIN EDVisits e ON p.PatientMRN = e.PatientMRN
    LEFT JOIN AmbulatoryVisits av ON p.PatientMRN = av.PatientMRN
    GROUP BY p.PatientMRN
),
HighUtilizers AS (
    SELECT
        pu.*,
        p.Gender,
        p.Race,
        p.Language,
        DATEDIFF(year, p.DateOfBirth, GETDATE()) AS Age,
        CASE
            WHEN pu.Total_ED_Visits >= 10 THEN 'Super High ED Utilizer (10+)'
            WHEN pu.Total_ED_Visits >= 4 THEN 'High ED Utilizer (4-9)'
            WHEN pu.Total_ED_Visits >= 2 THEN 'Moderate ED Utilizer (2-3)'
            WHEN pu.Total_ED_Visits = 1 THEN 'Single ED Visit'
            ELSE 'No ED Visits'
        END AS ED_Utilization_Category,
        CASE
            WHEN pu.Total_Ambulatory_Visits >= 20 THEN 'High Ambulatory Utilizer (20+)'
            WHEN pu.Total_Ambulatory_Visits >= 10 THEN 'Moderate Ambulatory Utilizer (10-19)'
            WHEN pu.Total_Ambulatory_Visits >= 1 THEN 'Low Ambulatory Utilizer (1-9)'
            ELSE 'No Ambulatory Visits'
        END AS Ambulatory_Utilization_Category
    FROM PatientUtilization pu
    JOIN Patients p ON pu.PatientMRN = p.PatientMRN
)
SELECT
    ED_Utilization_Category,
    Ambulatory_Utilization_Category,
    COUNT(*) AS Patient_Count,
    ROUND(AVG(CAST(Age AS FLOAT)), 1) AS Average_Age,
    AVG(Total_ED_Visits) AS Avg_Total_ED_Visits,
    AVG(Total_Ambulatory_Visits) AS Avg_Total_Ambulatory_Visits,
    AVG(ED_Visits_90_Days) AS Avg_ED_Visits_90_Days,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(10,2)) AS Percentage
FROM HighUtilizers
GROUP BY ED_Utilization_Category, Ambulatory_Utilization_Category
HAVING COUNT(*) >= 5
ORDER BY AVG(Total_ED_Visits) DESC, AVG(Total_Ambulatory_Visits) DESC;


--------------------------------------------------------------------------------------------
-- ED visit timing by day of week and hour
SELECT
    DATENAME(weekday, e.VisitDate) AS Day_of_Week,
     
    DATEPART(hour, e.VisitDate) AS Hour_of_Day,
    COUNT(*) AS ED_Visit_Count,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(10,2)) AS ED_Visit_Percentage
FROM EDVisits e
GROUP BY DATENAME(weekday, e.VisitDate), DATEPART(weekday, e.VisitDate), DATEPART(hour, e.VisitDate)
ORDER BY  ED_Visit_Count DESC;

--------------------------------------------
-- Acuity Distribution and Outcomes

SELECT
    e.Acuity,
    COUNT(*) AS Visit_Count,
    COUNT(DISTINCT e.PatientMRN) AS Unique_Patients,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER()AS DECIMAL(10,2)) AS Visit_Percentage,
    CAST(100.0 * SUM(CASE WHEN e.EDDisposition = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(10,2)) AS Admission_Rate,
    CAST(100.0 * SUM(CASE WHEN r.ReadmissionFlag = '1' THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(10,2)) AS Readmission_Rate,
    ROUND(AVG(CASE WHEN e.EDDischargeTime IS NOT NULL AND e.VisitDate IS NOT NULL
                   THEN DATEDIFF(minute, e.VisitDate, e.EDDischargeTime) END), 0) AS Avg_ED_LOS_Minutes
FROM EDVisits e
LEFT JOIN Discharges d 
ON e.PatientMRN = d.PatientID  
AND ABS(DATEDIFF(hour, e.VisitDate, d.AdmissionDate)) <= 24
LEFT JOIN ReadmissionRegistry r ON d.AdmissionID = r.AdmissionID
WHERE e.Acuity IS NOT NULL
GROUP BY e.Acuity
ORDER BY e.Acuity;

---------------------------------------------------------------------------------

-- Length of Stay : By acuity and disposition
WITH ED_LOS AS (
    SELECT
        e.EDvisitID,
        e.Acuity,
        e.EDDisposition,
        CASE
            WHEN e.EDDischargeTime IS NOT NULL AND e.VisitDate IS NOT NULL
            THEN DATEDIFF(minute, e.VisitDate, e.EDDischargeTime)
            ELSE NULL
        END AS LOS_Minutes
FROM EDVisits e
WHERE e.VisitDate IS NOT NULL
)
SELECT
    Acuity,
    EDDisposition,
    COUNT(*) AS Visit_Count,
    ROUND(AVG(CAST(LOS_Minutes AS FLOAT)), 0) AS Avg_LOS_Minutes,
    ROUND(AVG(CAST(LOS_Minutes AS FLOAT)) / 60.0, 2) AS Avg_LOS_Hours,
    MIN(LOS_Minutes) AS Min_LOS_Minutes,
    MAX(LOS_Minutes) AS Max_LOS_Minutes,
    COUNT(CASE WHEN LOS_Minutes > 240 THEN 1 END) AS Visits_Over_4_Hours,
    CAST(100.0 * COUNT(CASE WHEN LOS_Minutes > 240 THEN 1 END) / COUNT(*)AS DECIMAL(10,2)) AS Pct_Over_4_Hours
FROM ED_LOS
WHERE LOS_Minutes IS NOT NULL AND LOS_Minutes > 0
GROUP BY Acuity, EDDisposition
ORDER BY Acuity, EDDisposition;


----------------------------------------------
-- ED Disposition : Admission vs discharge rates
SELECT
    EDDisposition,
    COUNT(*) AS Visit_Count,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER()AS DECIMAL(10,2)) AS Visit_Percentage
FROM EDVisits
WHERE EDDisposition IS NOT NULL
GROUP BY EDDisposition
ORDER BY Visit_Percentage DESC;

---------------------------------------------------------------------------------
-- Reason for Visit

SELECT
    ReasonForVisit,
    COUNT(*) AS Visit_Count,
    COUNT(DISTINCT PatientMRN) AS Unique_Patients,
    CAST(100.0 * SUM(CASE WHEN Acuity IN ('1', '2') THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(10,2)) AS High_Acuity_Percentage,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER()AS DECIMAL(10,2)) AS Visit_Percentage
FROM EDVisits 
WHERE ReasonForVisit IS NOT NULL
GROUP BY ReasonForVisit
ORDER BY Visit_Count DESC;

-----------------------------------------------------------
-- 30-Day Readmission: By service and diagnosis

SELECT
    r.Service,
    r.PrimaryDiagnosis,
    COUNT(*) AS Total_Index_Admissions,
    SUM(CASE WHEN r.ReadmissionFlag = '1' THEN 1 ELSE 0 END) AS Readmissions_30_Day,
    CAST(100.0 * SUM(CASE WHEN r.ReadmissionFlag = '1' THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(10,2)) AS Readmission_Rate_30_Day,
    ROUND(AVG(r.DaysToreadmission), 1) AS Avg_Days_To_Readmission,
    ROUND(AVG(r.ExpectedLOS), 2) AS Avg_Index_Expected_LOS,
    CAST(100.0 * SUM(CASE WHEN r.EDVisitAfterDischargeFlag = '1' THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(10,2)) AS ED_Return_Rate,
    ROUND(AVG(r.ExpectedMortality) * 100, 2) AS Avg_Expected_Mortality_Pct
FROM ReadmissionRegistry r
WHERE r.Service IS NOT NULL
AND r.PrimaryDiagnosis IS NOT NULL
GROUP BY r.Service, r.PrimaryDiagnosis

ORDER BY Readmission_Rate_30_Day DESC;
-------------------------------------------------------------------------------------------------------
-- Admission: Common diagnoses and patient characteristicsNS

SELECT
    d.PrimaryDiagnosis,
    d.Service,
    COUNT(*) AS Admission_Count,
    COUNT(DISTINCT d.PatientID) AS Unique_Patients,
    ROUND(AVG(DATEDIFF(year, p.DateOfBirth, d.AdmissionDate)), 1) AS Average_Age,
    ROUND(AVG(CASE WHEN d.DischargeDate IS NOT NULL AND d.AdmissionDate IS NOT NULL
                   THEN DATEDIFF(day, d.AdmissionDate, d.DischargeDate) END), 2) AS Avg_LOS_Days,
    ROUND(AVG(d.ExpectedLOS), 2) AS Expected_LOS_Days,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER()AS DECIMAL(10,2)) AS Admission_Percentage
FROM Discharges d
JOIN Patients p ON CAST(d.PatientID AS VARCHAR(50)) = p.PatientMRN
WHERE d.AdmissionDate IS NOT NULL
AND d.PrimaryDiagnosis IS NOT NULL
GROUP BY d.PrimaryDiagnosis, d.Service
ORDER BY Admission_Count DESC;

--------------------------------------------------

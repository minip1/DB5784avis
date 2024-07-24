--view 1
CREATE VIEW EmployeeDetails AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    p.PositionName,
    p.Salary,
    d.DepartmentName,
    ms.SpecialtyName,
    COALESCE(l.LeaveType, 'N/A') AS LeaveType,
    COALESCE(l.ReturnDate, TO_DATE('9999-12-31', 'YYYY-MM-DD')) AS ReturnDate,
    COALESCE(pr.Rating, 0) AS Rating,
    COALESCE(pr.ReviewDate, TO_DATE('9999-12-31', 'YYYY-MM-DD')) AS ReviewDate
FROM 
    Employee e
LEFT JOIN 
    Position p ON e.PositionID = p.PositionID
LEFT JOIN 
    Department d ON p.DepartmentID = d.DepartmentID
LEFT JOIN 
    MedicalSpecialty ms ON p.SpecialtyID = ms.SpecialtyID
LEFT JOIN 
    (SELECT EmployeeID, MAX(LeaveType) AS LeaveType, MAX(ReturnDate) AS ReturnDate 
     FROM Leave GROUP BY EmployeeID) l ON e.EmployeeID = l.EmployeeID
LEFT JOIN 
    (SELECT EmployeeID, MAX(Rating) AS Rating, MAX(ReviewDate) AS ReviewDate 
     FROM PerformanceReview GROUP BY EmployeeID) pr ON e.EmployeeID = pr.EmployeeID;

-- Query 1.1: Select distinct employees with non-null leave types, ordered by return date
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    DepartmentName,
    SpecialtyName,
    LeaveType,
    ReturnDate
FROM 
    EmployeeDetails
WHERE 
    LeaveType <> 'N/A'
ORDER BY 
    ReturnDate DESC;

-- Query 1.2: Calculate average salary for each department and specialty combination, ordered by average salary
SELECT 
    DepartmentName,
    SpecialtyName,
    AVG(Salary) AS AverageSalary
FROM 
    EmployeeDetails
GROUP BY 
    DepartmentName,
    SpecialtyName
ORDER BY 
    AverageSalary DESC;
    
--view 2
CREATE VIEW EmployeeTeamDetails AS
SELECT DISTINCT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    t.team_ID,
    t.team_name,
    t.speciality,
    d.DepartmentID,
    d.DepartmentName,
    d.DateEstablished,
    mr.maintenance_request_ID,
    mr.priority,
    mr.maintenance_request_description,
    r.report_ID,
    r.maintenance_report_description,
    r.report_date
FROM 
    Employee e
LEFT JOIN 
    member_of mo ON e.EmployeeID = mo.employee_ID
LEFT JOIN 
    team t ON mo.team_ID = t.team_ID
LEFT JOIN 
    department d ON t.departmant_ID = d.DepartmentID
LEFT JOIN 
    maintenance_request mr ON d.DepartmentID = mr.departmant_ID
LEFT JOIN 
    worked w ON t.team_ID = w.team_ID
LEFT JOIN 
    maintenance_report r ON w.report_ID = r.report_ID
LEFT JOIN 
    used u ON r.report_ID = u.report_ID;

--query 2.1

SELECT DISTINCT
    et.EmployeeID, 
    et.FirstName, 
    et.LastName, 
    et.team_ID, 
    et.team_name, 
    et.speciality
FROM 
    EmployeeTeamDetails et
WHERE 
    et.team_ID IS NOT NULL;

--query 2.2
SELECT DISTINCT
    maintenance_request_ID,
    priority,
    maintenance_request_description,
    DepartmentName,
    DateEstablished
FROM 
    EmployeeTeamDetails
WHERE 
    maintenance_request_ID IS NOT NULL
ORDER BY
    priority DESC;

SELECT equipment_ID, equipment_name, usage_count
FROM (
    SELECT e.equipment_ID, e.equipment_name, COUNT(u.equipment_ID) AS usage_count
    FROM equipment e
    JOIN used u ON e.equipment_ID = u.equipment_ID
    GROUP BY e.equipment_ID, e.equipment_name
    ORDER BY usage_count DESC
)
WHERE ROWNUM <= 10;
SELECT departmant_ID, departmant_name, request_count
FROM (
    SELECT d.departmant_ID, d.departmant_name, COUNT(mr.maintenance_request_ID) AS request_count
    FROM departmant d
    JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
    GROUP BY d.departmant_ID, d.departmant_name
    ORDER BY request_count DESC
)
WHERE ROWNUM <= 5;
SELECT team_ID, team_name, report_count
FROM (
    SELECT t.team_ID, t.team_name, COUNT(w.report_ID) AS report_count
    FROM team t
    JOIN worked w ON t.team_ID = w.team_ID
    GROUP BY t.team_ID, t.team_name
    ORDER BY report_count DESC
)
WHERE ROWNUM <= 5;
SELECT team_ID, team_name, member_count
FROM (
    SELECT t.team_ID, t.team_name, COUNT(mo.employee_ID) AS member_count
    FROM team t
    JOIN member_of mo ON t.team_ID = mo.team_ID
    GROUP BY t.team_ID, t.team_name
    ORDER BY member_count DESC
)
WHERE ROWNUM = 1;
WITH LatestUsage AS (
    SELECT u.equipment_ID, MAX(mr.report_date) AS latest_date
    FROM used u
    JOIN maintenance_report mr ON u.report_ID = mr.report_ID
    GROUP BY u.equipment_ID
    ORDER BY latest_date DESC
    FETCH FIRST 5 ROWS ONLY
)
SELECT lu.equipment_ID, e.equipment_name,
       TO_CHAR(lu.latest_date, 'YYYY-MM-DD') AS report_date,
       TO_CHAR(lu.latest_date, 'DD') AS day,
       TO_CHAR(lu.latest_date, 'MM') AS month
FROM LatestUsage lu
JOIN equipment e ON lu.equipment_ID = e.equipment_ID
ORDER BY lu.latest_date DESC;

SELECT *
FROM maintenance_report
WHERE 
  report_date BETWEEN &<name = d_from type = date> AND &<name = d_to type = date>;
  
SELECT e.employee_name, e.employee_last_name
FROM employee e
JOIN departmant d ON e.employee_ID = d.superviser_ID
WHERE d.departmant_ID = &<name = dep_id type = string>;

SELECT e.employee_name, e.employee_last_name, t.team_name
FROM employee e
JOIN member_of m ON e.employee_ID = m.employee_ID
JOIN team t ON m.team_ID = t.team_ID
WHERE e.employee_ID = &<name = emp_id type = string>;

SELECT mr.maintenance_report_description, mr.report_date
FROM maintenance_report mr
JOIN worked w ON mr.report_ID = w.report_ID
JOIN team t ON w.team_ID = t.team_ID
WHERE t.team_ID =  &<name = team type = string>;

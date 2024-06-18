UPDATE maintenance_request
SET priority = priority + 1
WHERE departmant_ID = (
    SELECT departmant_ID
    FROM (
        SELECT departmant_ID, COUNT(*) AS request_count
        FROM maintenance_request
        GROUP BY departmant_ID
        ORDER BY request_count DESC
        FETCH FIRST 1 ROW ONLY
    ) dept_with_most_requests
);
UPDATE equipment
SET purchase_date = CURRENT_DATE
WHERE equipment_ID IN (
    SELECT equipment_ID
    FROM (
        SELECT equipment_ID, COUNT(*) AS usage_count
        FROM used
        GROUP BY equipment_ID
        ORDER BY usage_count DESC
        FETCH FIRST 10 ROWS ONLY
    ) most_used_equipment
);

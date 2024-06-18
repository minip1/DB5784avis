DELETE FROM member_of
WHERE team_ID IN (
    SELECT team_ID
    FROM (
        SELECT t.team_ID, COUNT(w.report_ID) AS report_count
        FROM team t
        LEFT JOIN worked w ON t.team_ID = w.team_ID
        GROUP BY t.team_ID
        ORDER BY report_count ASC
    )
    WHERE ROWNUM <= 10
);

DELETE FROM worked
WHERE team_ID IN (
    SELECT team_ID
    FROM (
        SELECT t.team_ID, COUNT(w.report_ID) AS report_count
        FROM team t
        LEFT JOIN worked w ON t.team_ID = w.team_ID
        GROUP BY t.team_ID
        ORDER BY report_count ASC
    )
    WHERE ROWNUM <= 10
);
DELETE FROM team
WHERE team_ID IN (
    SELECT team_ID
    FROM (
        SELECT t.team_ID, COUNT(w.report_ID) AS report_count
        FROM team t
        LEFT JOIN worked w ON t.team_ID = w.team_ID
        GROUP BY t.team_ID
        ORDER BY report_count ASC
    )
    WHERE ROWNUM <= 10
);
DELETE FROM used
WHERE equipment_ID IN (
    SELECT equipment_ID
    FROM (
        SELECT e.equipment_ID, COUNT(u.equipment_ID) AS usage_count
        FROM equipment e
        LEFT JOIN used u ON e.equipment_ID = u.equipment_ID
        GROUP BY e.equipment_ID
        ORDER BY usage_count ASC
    )
    WHERE ROWNUM <= 10
);
DELETE FROM equipment
WHERE equipment_ID IN (
    SELECT equipment_ID
    FROM (
        SELECT e.equipment_ID, COUNT(u.equipment_ID) AS usage_count
        FROM equipment e
        LEFT JOIN used u ON e.equipment_ID = u.equipment_ID
        GROUP BY e.equipment_ID
        ORDER BY usage_count ASC
    )
    WHERE ROWNUM <= 10
);

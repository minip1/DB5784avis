CREATE OR REPLACE FUNCTION print_departments_and_teams
RETURN VARCHAR2
IS
    v_output VARCHAR2(4000);
    v_max_dept_id INT;
    v_min_dept_id INT;
BEGIN
    -- Find department with the most maintenance requests
    SELECT departmant_ID INTO v_max_dept_id
    FROM (
        SELECT d.departmant_ID, COUNT(*) AS cnt
        FROM departmant d
        JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
        GROUP BY d.departmant_ID
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;

    -- Find department with the least maintenance requests
    SELECT departmant_ID INTO v_min_dept_id
    FROM (
        SELECT d.departmant_ID, COUNT(*) AS cnt
        FROM departmant d
        JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
        GROUP BY d.departmant_ID
        ORDER BY cnt ASC
    )
    WHERE ROWNUM = 1;

    -- Build output string for departments and their teams
    v_output := 'Department with most requests:' || CHR(10);
    v_output := v_output || '---------------------------' || CHR(10);
    v_output := v_output || 'Department ID: ' || v_max_dept_id || CHR(10);

    -- Teams in department with most requests
    FOR team_rec IN (
        SELECT t.team_ID, t.team_name
        FROM team t
        WHERE t.departmant_ID = v_max_dept_id
    )
    LOOP
        v_output := v_output || 'Team ID: ' || team_rec.team_ID || ', Team Name: ' || team_rec.team_name || CHR(10);
    END LOOP;

    v_output := v_output || CHR(10);

    v_output := v_output || 'Department with least requests:' || CHR(10);
    v_output := v_output || '----------------------------' || CHR(10);
    v_output := v_output || 'Department ID: ' || v_min_dept_id || CHR(10);

    -- Teams in department with least requests
    FOR team_rec IN (
        SELECT t.team_ID, t.team_name
        FROM team t
        WHERE t.departmant_ID = v_min_dept_id
    )
    LOOP
        v_output := v_output || 'Team ID: ' || team_rec.team_ID || ', Team Name: ' || team_rec.team_name || CHR(10);
    END LOOP;

    -- Return the output string
    RETURN v_output;
END;
/


DECLARE
    v_result VARCHAR2(4000);
BEGIN
    -- Call the procedure to move teams between departments
    move_teams_between_departments();

    -- Call the function to print departments and their teams
    v_result := print_departments_and_teams();

    -- Print the result
    DBMS_OUTPUT.PUT_LINE(v_result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Rollback in case of error
END;
/

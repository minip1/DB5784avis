CREATE OR REPLACE FUNCTION find_departments_with_requests
RETURN SYS.ODCINUMBERLIST
IS
    v_max_dept_id INT;
    v_min_dept_id INT;
    v_result SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
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

    -- Add the department IDs to the result list
    v_result.EXTEND(2);
    v_result(1) := v_max_dept_id;
    v_result(2) := v_min_dept_id;

    RETURN v_result;
END;
/
CREATE OR REPLACE PROCEDURE move_teams_between_departments
IS
    v_max_dept_id INT;
    v_min_dept_ids SYS.ODCINUMBERLIST;
BEGIN
    -- Get the department ID with the most maintenance requests
    SELECT departmant_ID INTO v_max_dept_id
    FROM (
        SELECT d.departmant_ID, COUNT(*) AS cnt
        FROM departmant d
        JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
        GROUP BY d.departmant_ID
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;

    -- Get the department IDs with the least maintenance requests
    SELECT departmant_ID BULK COLLECT INTO v_min_dept_ids
    FROM (
        SELECT d.departmant_ID, COUNT(*) AS cnt
        FROM departmant d
        JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
        GROUP BY d.departmant_ID
        ORDER BY cnt ASC
    )
    WHERE ROWNUM <= 5;

    -- Move one team from each of the departments with the least requests to the department with the most requests
    FOR i IN 1..v_min_dept_ids.COUNT LOOP
        DECLARE
            v_team_id INT;
        BEGIN
            -- Select one team from the current v_min_dept_ids(i) to move
            SELECT team_ID INTO v_team_id
            FROM (
                SELECT t.team_ID, ROW_NUMBER() OVER (ORDER BY t.team_ID) AS rn
                FROM team t
                WHERE t.departmant_ID = v_min_dept_ids(i)
            )
            WHERE rn = 1; -- Select the first team (you can adjust this logic if needed)

            -- Update the team's department to v_max_dept_id
            UPDATE team
            SET departmant_ID = v_max_dept_id
            WHERE team_ID = v_team_id;

            COMMIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No team found in department ' || v_min_dept_ids(i));
                -- You can handle the exception as per your requirement
        END;
    END LOOP;

    COMMIT;
END;
/

BEGIN
    move_teams_between_departments();
    DBMS_OUTPUT.PUT_LINE('Teams moved successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Rollback in case of error
END;
/

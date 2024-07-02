CREATE OR REPLACE FUNCTION find_departments_with_requests
RETURN SYS.ODCINUMBERLIST
IS
    v_max_dept_id INT;
    v_min_dept_ids SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
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

    -- Find departments with the least maintenance requests
    SELECT departmant_ID BULK COLLECT INTO v_min_dept_ids
    FROM (
        SELECT d.departmant_ID, COUNT(*) AS cnt
        FROM departmant d
        JOIN maintenance_request mr ON d.departmant_ID = mr.departmant_ID
        GROUP BY d.departmant_ID
        ORDER BY cnt ASC
    )
    WHERE ROWNUM <= 5;

    -- Add the department IDs to the result list
    v_min_dept_ids.EXTEND;
    v_min_dept_ids(v_min_dept_ids.COUNT) := v_max_dept_id;

    RETURN v_min_dept_ids;
END;
/
CREATE OR REPLACE PROCEDURE move_teams_between_departments
IS
    v_departments SYS.ODCINUMBERLIST;
    v_max_dept_id INT;
BEGIN
    -- Get the department IDs
    v_departments := find_departments_with_requests;

    -- The last element in v_departments is the department with the most requests
    v_max_dept_id := v_departments(v_departments.COUNT);

    -- Move one team from each of the departments with the least requests to the department with the most requests
    FOR i IN 1..v_departments.COUNT-1 LOOP
        DECLARE
            v_team_id INT;
        BEGIN
            -- Print initial state of the least worked team
            DBMS_OUTPUT.PUT_LINE('Initial State of Least Worked Team (Department ID: ' || v_departments(i) || '):');
            DBMS_OUTPUT.PUT_LINE(get_team_state(v_departments(i)));
            
            -- Select one team from the current v_departments(i) to move
            SELECT team_ID INTO v_team_id
            FROM (
                SELECT t.team_ID, ROW_NUMBER() OVER (ORDER BY t.team_ID) AS rn
                FROM team t
                WHERE t.departmant_ID = v_departments(i)
            )
            WHERE rn = 1; -- Select the first team

            -- Update the team's department to v_max_dept_id
            UPDATE team
            SET departmant_ID = v_max_dept_id
            WHERE team_ID = v_team_id;

            COMMIT;

            -- Print moved employee details
            DBMS_OUTPUT.PUT_LINE('Moved team ' || v_team_id || ' from Department ' || v_departments(i) || ' to Department ' || v_max_dept_id);

            -- Print final state of the least worked team after move
            DBMS_OUTPUT.PUT_LINE('Final State of Least Worked Team (Department ID: ' || v_departments(i) || '):');
            DBMS_OUTPUT.PUT_LINE(get_team_state(v_departments(i)));

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No team found in department ' || v_departments(i));
        END;
    END LOOP;

    -- Print final state of the most worked team
    DBMS_OUTPUT.PUT_LINE('Final State of Most Worked Team (Department ID: ' || v_max_dept_id || '):');
    DBMS_OUTPUT.PUT_LINE(get_team_state(v_max_dept_id));

    DBMS_OUTPUT.PUT_LINE('Teams moved successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Rollback in case of error
END;
/

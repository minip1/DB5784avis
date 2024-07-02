CREATE OR REPLACE FUNCTION find_teams_most_least_worked
RETURN SYS.ODCINUMBERLIST
IS
    v_most_worked_team_id INT;
    v_least_worked_teams SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
BEGIN
    -- Find team with the most work
    SELECT team_ID INTO v_most_worked_team_id
    FROM (
        SELECT wt.team_ID, COUNT(*) AS num_reports
        FROM worked wt
        JOIN maintenance_report mr ON wt.report_ID = mr.report_ID
        GROUP BY wt.team_ID
        ORDER BY num_reports DESC
    )
    WHERE ROWNUM = 1;

    -- Find teams with the least work
    SELECT team_ID BULK COLLECT INTO v_least_worked_teams
    FROM (
        SELECT wt.team_ID, COUNT(*) AS num_reports
        FROM worked wt
        JOIN maintenance_report mr ON wt.report_ID = mr.report_ID
        GROUP BY wt.team_ID
        ORDER BY num_reports ASC
    )
    WHERE ROWNUM <= 5;

    -- Add the team with the most work to the result list
    v_least_worked_teams.EXTEND;
    v_least_worked_teams(v_least_worked_teams.COUNT) := v_most_worked_team_id;

    RETURN v_least_worked_teams;
END;
/

CREATE OR REPLACE FUNCTION get_team_state(p_team_id INT)
RETURN VARCHAR2
IS
    v_output VARCHAR2(4000);
    v_team_name VARCHAR2(100);
    v_speciality VARCHAR2(100);
    v_member_count INT;
    v_supervisor_id INT;
BEGIN
    -- Get team details
    SELECT team_name, speciality
    INTO v_team_name, v_speciality
    FROM team
    WHERE team_ID = p_team_id;

    -- Get member count
    SELECT COUNT(*)
    INTO v_member_count
    FROM member_of
    WHERE team_ID = p_team_id;

    -- Get supervisor ID
    SELECT superviser_ID
    INTO v_supervisor_id
    FROM departmant
    WHERE departmant_ID = (
        SELECT departmant_ID
        FROM team
        WHERE team_ID = p_team_id
    );

    -- Build output string for the team state
    v_output := 'Team Name: ' || v_team_name || CHR(10);
    v_output := v_output || 'Speciality: ' || v_speciality || CHR(10);
    v_output := v_output || 'Member Count: ' || v_member_count || CHR(10);
    v_output := v_output || 'Supervisor ID: ' || v_supervisor_id || CHR(10);

    -- List members of the team
    v_output := v_output || 'Members:' || CHR(10);
    FOR member_rec IN (
        SELECT e.employee_name || ' ' || e.employee_last_name AS member_name
        FROM member_of m
        JOIN employee e ON m.employee_ID = e.employee_ID
        WHERE m.team_ID = p_team_id
    )
    LOOP
        v_output := v_output || ' - ' || member_rec.member_name || CHR(10);
    END LOOP;

    RETURN v_output;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No data found for team ' || p_team_id;
    WHEN OTHERS THEN
        RETURN 'Error fetching team state: ' || SQLERRM;
END;
/
CREATE OR REPLACE PROCEDURE move_employees_to_most_worked_team_with_state
IS
    v_teams SYS.ODCINUMBERLIST;
    v_most_worked_team_id INT;
    v_output VARCHAR2(4000);
BEGIN
    -- Get the team IDs
    v_teams := find_teams_most_least_worked;

    -- The last element in v_teams is the team with the most work
    v_most_worked_team_id := v_teams(v_teams.COUNT);

    -- Print initial state of the most worked team
    v_output := 'Initial State of Most Worked Team (Team ID: ' || v_most_worked_team_id || '):' || CHR(10);
    v_output := v_output || get_team_state(v_most_worked_team_id) || CHR(10);

    FOR i IN 1..v_teams.COUNT-1 LOOP
        DECLARE
            v_team_id INT := v_teams(i);
            v_supervisor_id INT;
            v_employee_id INT;
        BEGIN
            -- Print initial state of the least worked team
            v_output := v_output || 'Initial State of Least Worked Team (Team ID: ' || v_team_id || '):' || CHR(10);
            v_output := v_output || get_team_state(v_team_id) || CHR(10);

            -- Select one non-supervisor employee from the current team to move
            SELECT employee_ID INTO v_employee_id
            FROM (
                SELECT m.employee_ID, ROW_NUMBER() OVER (ORDER BY m.employee_ID) AS rn
                FROM member_of m
                WHERE m.team_ID = v_team_id
                AND m.employee_ID != (
                    SELECT superviser_ID
                    FROM departmant d
                    WHERE d.departmant_ID = (
                        SELECT t.departmant_ID
                        FROM team t
                        WHERE t.team_ID = v_team_id
                    )
                )
            )
            WHERE rn = 1; -- Select the first non-supervisor employee

            -- Move the employee to the most worked team
            UPDATE member_of
            SET team_ID = v_most_worked_team_id
            WHERE employee_ID = v_employee_id
            AND team_ID = v_team_id;

            COMMIT;

            -- Print moved employee details
            v_output := v_output || 'Moved employee ' || v_employee_id || ' from Team ' || v_team_id || ' to Team ' || v_most_worked_team_id || CHR(10);

            -- Print final state of the least worked team after move
            v_output := v_output || 'Final State of Least Worked Team (Team ID: ' || v_team_id || '):' || CHR(10);
            v_output := v_output || get_team_state(v_team_id) || CHR(10);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_output := v_output || 'No eligible employee found in team ' || v_team_id || CHR(10);
            WHEN OTHERS THEN
                v_output := v_output || 'Error moving employee: ' || SQLERRM || CHR(10);
        END;
    END LOOP;

    -- Print final state of the most worked team
    v_output := v_output || 'Final State of Most Worked Team (Team ID: ' || v_most_worked_team_id || '):' || CHR(10);
    v_output := v_output || get_team_state(v_most_worked_team_id) || CHR(10);

    DBMS_OUTPUT.PUT_LINE(v_output);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
    move_employees_to_most_worked_team_with_state();
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

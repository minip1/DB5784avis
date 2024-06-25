CREATE OR REPLACE FUNCTION find_teams_most_least_worked
RETURN SYS.ODCINUMBERLIST
IS
    v_most_worked_team_id INT;
    v_least_worked_teams SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();
BEGIN
    -- Find team with the most work (most reports)
    SELECT team_ID INTO v_most_worked_team_id
    FROM (
        SELECT wt.team_ID, COUNT(*) AS num_reports
        FROM worked wt
        JOIN maintenance_report mr ON wt.report_ID = mr.report_ID
        GROUP BY wt.team_ID
        ORDER BY num_reports DESC
    )
    WHERE ROWNUM = 1;

    -- Find teams with the least work (least reports), excluding the most worked team
    SELECT team_ID BULK COLLECT INTO v_least_worked_teams
    FROM (
        SELECT wt.team_ID, COUNT(*) AS num_reports
        FROM worked wt
        JOIN maintenance_report mr ON wt.report_ID = mr.report_ID
        WHERE wt.team_ID <> v_most_worked_team_id
        GROUP BY wt.team_ID
        ORDER BY num_reports ASC
    )
    WHERE ROWNUM <= 5;

    RETURN v_least_worked_teams;
END;
/
CREATE OR REPLACE PROCEDURE move_employees_to_most_worked_team_with_state
IS
    v_most_worked_team_id INT;
    v_least_worked_teams SYS.ODCINUMBERLIST;
BEGIN
    -- Get the team with the most work and the least worked teams
    v_least_worked_teams := find_teams_most_least_worked;
    
    -- Get the team with the most work
    SELECT team_ID INTO v_most_worked_team_id
    FROM (
        SELECT wt.team_ID, COUNT(*) AS num_reports
        FROM worked wt
        JOIN maintenance_report mr ON wt.report_ID = mr.report_ID
        GROUP BY wt.team_ID
        ORDER BY num_reports DESC
    )
    WHERE ROWNUM = 1;

    -- Print initial state of each team
    FOR i IN 1..v_least_worked_teams.COUNT LOOP
        DECLARE
            v_team_id INT := v_least_worked_teams(i);
            v_team_name VARCHAR2(100);
            v_speciality VARCHAR2(100);
            v_member_count INT;
            v_supervisor_id INT;
            v_initial_state VARCHAR2(4000);
        BEGIN
            -- Get initial state of the team
            SELECT team_name, speciality
            INTO v_team_name, v_speciality
            FROM team
            WHERE team_ID = v_team_id;

            -- Get member count
            SELECT COUNT(*)
            INTO v_member_count
            FROM member_of
            WHERE team_ID = v_team_id;

            -- Get supervisor ID
            SELECT superviser_ID
            INTO v_supervisor_id
            FROM departmant
            WHERE departmant_ID = (
                SELECT departmant_ID
                FROM team
                WHERE team_ID = v_team_id
            );

            -- Build initial state output
            v_initial_state := 'Initial State of Team ' || v_team_id || ':' || CHR(10);
            v_initial_state := v_initial_state || '-------------------------' || CHR(10);
            v_initial_state := v_initial_state || 'Team Name: ' || v_team_name || CHR(10);
            v_initial_state := v_initial_state || 'Speciality: ' || v_speciality || CHR(10);
            v_initial_state := v_initial_state || 'Member Count: ' || v_member_count || CHR(10);
            v_initial_state := v_initial_state || 'Supervisor ID: ' || v_supervisor_id || CHR(10);

            -- Print initial state
            DBMS_OUTPUT.PUT_LINE(v_initial_state);

            -- Move one employee from the least worked team to the most worked team
            DECLARE
                v_employee_id INT;
            BEGIN
                -- Select one employee from the current team to move
                SELECT employee_ID INTO v_employee_id
                FROM (
                    SELECT m.employee_ID, ROW_NUMBER() OVER (ORDER BY m.employee_ID) AS rn
                    FROM member_of m
                    WHERE m.team_ID = v_team_id
                    AND EXISTS (
                        SELECT 1
                        FROM member_of ms
                        WHERE ms.team_ID = v_team_id
                        GROUP BY ms.team_ID
                        HAVING COUNT(*) > 1
                    )
                )
                WHERE rn = 1; -- Select the first employee (you can adjust this logic if needed)

                -- Update the employee's team to the most worked team
                UPDATE member_of
                SET team_ID = v_most_worked_team_id
                WHERE employee_ID = v_employee_id
                AND team_ID = v_team_id;

                COMMIT;

                -- Print moved employee details
                DBMS_OUTPUT.PUT_LINE('Moved employee ' || v_employee_id || ' from Team ' || v_team_id || ' to Team ' || v_most_worked_team_id);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No eligible employee found in team ' || v_team_id);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error moving employee: ' || SQLERRM);
            END;

            -- Print final state of the team after move
            DECLARE
                v_final_state VARCHAR2(4000);
            BEGIN
                -- Get final state of the team after move
                SELECT team_name, speciality
                INTO v_team_name, v_speciality
                FROM team
                WHERE team_ID = v_team_id;

                -- Get member count
                SELECT COUNT(*)
                INTO v_member_count
                FROM member_of
                WHERE team_ID = v_team_id;

                -- Get supervisor ID
                SELECT superviser_ID
                INTO v_supervisor_id
                FROM departmant
                WHERE departmant_ID = (
                    SELECT departmant_ID
                    FROM team
                    WHERE team_ID = v_team_id
                );

                -- Build final state output
                v_final_state := 'Final State of Team ' || v_team_id || ':' || CHR(10);
                v_final_state := v_final_state || '-------------------------' || CHR(10);
                v_final_state := v_final_state || 'Team Name: ' || v_team_name || CHR(10);
                v_final_state := v_final_state || 'Speciality: ' || v_speciality || CHR(10);
                v_final_state := v_final_state || 'Member Count: ' || v_member_count || CHR(10);
                v_final_state := v_final_state || 'Supervisor ID: ' || v_supervisor_id || CHR(10);

                -- Print final state
                DBMS_OUTPUT.PUT_LINE(v_final_state);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No data found for team ' || v_team_id);
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error fetching team state: ' || SQLERRM);
            END;
        END;
    END LOOP;

    COMMIT;
END;
/
BEGIN
    move_employees_to_most_worked_team_with_state();
    DBMS_OUTPUT.PUT_LINE('Employee movement and team state printed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; -- Rollback in case of error
END;
/

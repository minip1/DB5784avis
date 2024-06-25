CREATE OR REPLACE FUNCTION print_most_worked_team
RETURN VARCHAR2
IS
    v_output VARCHAR2(4000);
    v_most_worked_team_id INT;
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

    -- Build output string for the most worked team
    v_output := 'Most Worked Team:' || CHR(10);
    v_output := v_output || '-----------------' || CHR(10);
    v_output := v_output || 'Team ID: ' || v_most_worked_team_id || CHR(10);

    -- Get team details
    SELECT team_name, speciality
    INTO v_output
    FROM team
    WHERE team_ID = v_most_worked_team_id;

    -- Append team details to output string
    v_output := v_output || 'Team Name: ' || team_name || CHR(10);
    v_output := v_output || 'Speciality: ' || speciality || CHR(10);

    -- List members of the team
    v_output := v_output || 'Members:' || CHR(10);
    FOR member_rec IN (
        SELECT e.employee_name || ' ' || e.employee_last_name AS member_name
        FROM member_of m
        JOIN employee e ON m.employee_ID = e.employee_ID
        WHERE m.team_ID = v_most_worked_team_id
    )
    LOOP
        v_output := v_output || ' - ' || member_rec.member_name || CHR(10);
    END LOOP;

    RETURN v_output;
END;
/
DECLARE
    v_result VARCHAR2(4000);
BEGIN
    -- Call the function to print details about the most worked team
    v_result := print_most_worked_team();

    -- Print the result
    DBMS_OUTPUT.PUT_LINE(v_result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

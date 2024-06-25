CREATE OR REPLACE FUNCTION ensure_supervisors_are_members
RETURN VARCHAR2
IS
    v_output VARCHAR2(4000);
BEGIN
    v_output := 'Fixing supervisors who are not members of their teams:' || CHR(10);
    v_output := v_output || '--------------------------------------------' || CHR(10);

    -- Iterate through each department
    FOR dept_rec IN (
        SELECT d.departmant_ID, d.superviser_ID
        FROM departmant d
    ) LOOP
        DECLARE
            v_supervisor_id INT := dept_rec.superviser_ID;
            v_team_id INT;
            v_member_count INT;
        BEGIN
            -- Get the team ID for the supervisor's department
            SELECT t.team_ID
            INTO v_team_id
            FROM team t
            WHERE t.departmant_ID = dept_rec.departmant_ID;

            -- Check if supervisor is already a member of the team
            SELECT COUNT(*)
            INTO v_member_count
            FROM member_of m
            WHERE m.team_ID = v_team_id
            AND m.employee_ID = v_supervisor_id;

            -- If supervisor is not a member, add them to the team
            IF v_member_count = 0 THEN
                INSERT INTO member_of (team_ID, employee_ID)
                VALUES (v_team_id, v_supervisor_id);
                
                COMMIT; -- Commit transaction

                v_output := v_output || 'Added supervisor ' || v_supervisor_id || ' to Team ' || v_team_id || CHR(10);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_output := v_output || 'No team found for department ' || dept_rec.departmant_ID || CHR(10);
            WHEN OTHERS THEN
                v_output := v_output || 'Error: ' || SQLERRM || CHR(10);
        END;
    END LOOP;

    RETURN v_output;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/
DECLARE
    v_result VARCHAR2(4000);
BEGIN
    v_result := ensure_supervisors_are_members();
    DBMS_OUTPUT.PUT_LINE(v_result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

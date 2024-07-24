-- First, insert the positions
BEGIN
  INSERT INTO Position (PositionId, PositionName, Salary)
  VALUES (1000, 'electrician', 20000);

  INSERT INTO Position (PositionId, PositionName, Salary)
  VALUES (1001, 'cleaner', 15000);

  INSERT INTO Position (PositionId, PositionName, Salary)
  VALUES (1002, 'plumber', 25000);

  INSERT INTO Position (PositionId, PositionName, Salary)
  VALUES (1003, 'maintenance worker', 17000);
END;
/

DECLARE
  CURSOR emp_cursor IS
    SELECT e.employee_ID, e.employee_name, e.employee_last_name, MAX(t.speciality) AS speciality
    FROM employee e
    JOIN member_of mo ON e.employee_ID = mo.employee_ID
    JOIN team t ON mo.team_ID = t.team_ID
    GROUP BY e.employee_ID, e.employee_name, e.employee_last_name;

  l_position_id Position.PositionID%TYPE;

BEGIN
  FOR emp_rec IN emp_cursor LOOP
    -- Determine the position ID based on the speciality
    CASE emp_rec.speciality
      WHEN 'electric' THEN l_position_id := 1000;
      WHEN 'cleaning' THEN l_position_id := 1001;
      WHEN 'plumbing' THEN l_position_id := 1002;
      WHEN 'repairs' THEN l_position_id := 1003;
      ELSE l_position_id := NULL; -- If the speciality doesn't match any known speciality
    END CASE;

    -- Insert into Employee1 table
    INSERT INTO Employee1 (EmployeeID, FirstName, LastName, PositionID)
    VALUES (emp_rec.employee_ID, emp_rec.employee_name, emp_rec.employee_last_name, l_position_id);
  END LOOP;
END;
/

DECLARE
  CURSOR dept_cursor IS
    SELECT departmant_ID, departmant_name
    FROM departmant;

  l_date_established DATE;
BEGIN
  FOR dept_rec IN dept_cursor LOOP
    -- Generate a random date between 17/10/2010 and 26/12/2020
    l_date_established := TRUNC(TO_DATE('17/10/2010', 'DD/MM/YYYY') + DBMS_RANDOM.VALUE(0, 3748)); -- 3748 days between the two dates

    -- Insert into Department1 table with '1' prefix before departmant_ID
    INSERT INTO Department1 (DepartmentID, DepartmentName, DateEstablished)
    VALUES (dept_rec.departmant_ID + 1000, dept_rec.departmant_name, l_date_established);
  END LOOP;
END;
/

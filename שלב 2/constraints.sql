ALTER TABLE employee
MODIFY (employee_name VARCHAR(100),
        employee_last_name VARCHAR(100) NOT NULL);
ALTER TABLE maintenance_request
ADD CONSTRAINT chk_priority CHECK (priority BETWEEN 1 AND 10);

ALTER TABLE equipment
MODIFY (purchase_date DATE DEFAULT SYSDATE);

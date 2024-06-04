-- Drop tables if they exist to avoid conflicts
-- Create employee table
CREATE TABLE employee (
  employee_ID INT NOT NULL,
  employee_name VARCHAR(100) NOT NULL,
  employee_last_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (employee_ID)
);

-- Create departmant table
CREATE TABLE departmant (
  departmant_ID INT NOT NULL,
  departmant_name VARCHAR(100) NOT NULL,
  superviser_ID INT NOT NULL,
  PRIMARY KEY (departmant_ID),
  FOREIGN KEY (superviser_ID) REFERENCES employee(employee_ID)
);
-- Create team table
CREATE TABLE team (
  team_ID INT NOT NULL,
  team_name VARCHAR(100) NOT NULL,
  speciality VARCHAR(100) NOT NULL,
  departmant_ID INT NOT NULL,
  PRIMARY KEY (team_ID),
  FOREIGN KEY (departmant_ID) REFERENCES departmant(departmant_ID)
);
CREATE TABLE member_of(
  team_ID INT,
  employee_ID INT NOT NULL,
  FOREIGN KEY (team_ID) REFERENCES team(team_ID),
  FOREIGN KEY (employee_ID) REFERENCES employee(employee_ID)
  );
-- Create equipment table
CREATE TABLE equipment (
  equipment_ID INT NOT NULL,
  equipment_name VARCHAR(100) NOT NULL,
  purchase_date DATE NOT NULL,
  PRIMARY KEY (equipment_ID)
);

-- Create maintenance_request table
CREATE TABLE maintenance_request (
  maintenance_request_ID INT NOT NULL,
  priority INT NOT NULL,
  maintenance_request_description VARCHAR(300) NOT NULL,
  departmant_ID INT NOT NULL,
  PRIMARY KEY (maintenance_request_ID),
  FOREIGN KEY (departmant_ID) REFERENCES departmant(departmant_ID)
);

-- Create maintenance_report table
CREATE TABLE maintenance_report (
  report_ID INT NOT NULL,
  maintenance_report_description VARCHAR(300) NOT NULL,
  report_date DATE NOT NULL,
  PRIMARY KEY (report_ID)
);

-- Create worked table
CREATE TABLE worked (
  team_ID INT NOT NULL,
  report_ID INT NOT NULL,
  PRIMARY KEY (team_ID, report_ID),
  FOREIGN KEY (team_ID) REFERENCES team(team_ID),
  FOREIGN KEY (report_ID) REFERENCES maintenance_report(report_ID)
);

-- Create used table
CREATE TABLE used (
  report_ID INT NOT NULL,
  equipment_ID INT NOT NULL,
  PRIMARY KEY (report_ID, equipment_ID),
  FOREIGN KEY (report_ID) REFERENCES maintenance_report(report_ID),
  FOREIGN KEY (equipment_ID) REFERENCES equipment(equipment_ID)
);


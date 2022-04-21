DROP DATABASE advising_pathways;
CREATE DATABASE IF NOT EXISTS advising_pathways;
USE advising_pathways;

/*
Accounts/Login
==============
The user table stores both students and advisors. Username is the primary key used to 
identify users throughout the system. 
*/
CREATE TABLE user (
	username		VARCHAR(255) NOT NULL,
    email 			VARCHAR(255) NOT NULL,
    first_name 		VARCHAR(255),
    last_name 		VARCHAR(255),
    is_student		BOOLEAN,
    is_advisor		BOOLEAN,
    password 		VARCHAR(255),
    PRIMARY KEY (username)
);

/*
Cirriculum Planning
===================
For a user to plan their classes, we must store information on what classes are offered, when 
those classes are offered, prerequisited between classes, thread requirements, and classes a 
student has completed. Classes are defined by their department (CS, MATH, etc) and their number. 
Requirements are stored as a list of class options. There are two primary objects. First, a class
list is simply a list of multiple classes. This is used both for prerequisites and requirments.
Second, there is a class requirement option. These are a list of classes where the student has to
take at least x amount of credits within those classes.
*/
CREATE TABLE class (
	department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    class_name 			VARCHAR(255),
    class_description 	VARCHAR(2047),
    PRIMARY KEY (department, class_number)
);

CREATE TABLE when_class_offered (
	offered_id 			INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	department 			VARCHAR(255) NOT NULL,
    class_number 		INT NOT NULL,
    semester 			ENUM('SPRING', 'FALL', 'SUMMER'),
    instructor 			VARCHAR(255),
    days 				TINYINT, -- bit vector for M-F (last 3 bits not used)
    start_time 			TIME,
    end_time 			TIME,
    building 			VARCHAR(255),
    room 				INT,
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

CREATE TABLE class_list (
	class_list_id 		INT NOT NULL PRIMARY KEY,
    class_list_name 	VARCHAR(255) NOT NULL,
    department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

-- List of class lists representing an AND or OR requirements (class list)
CREATE TABLE class_prerequisite (
	prereq_id 			INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    class_list_name 	VARCHAR(255) NOT NULL,
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

-- Ignore the free elective hours field
CREATE TABLE thread (
	thread_name 		VARCHAR(255) NOT NULL PRIMARY KEY,
	fe_hrs_required 	INT NOT NULL -- free elective hours 
);

-- Note: num_hrs_required = -1 means that all classes in that list are required
CREATE TABLE thread_requirement (
	requirement_id 		INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	thread_name 		VARCHAR(255) NOT NULL,
    class_list_name 	VARCHAR(255) NOT NULL,
    num_hrs_required 	INT NOT NULL,
    FOREIGN KEY (thread_name) REFERENCES thread(thread_name)
);

CREATE TABLE completed_class (
	completed_class_id 	INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	username 			VARCHAR(255) NOT NULL,
    department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    FOREIGN KEY (username) REFERENCES user(username),
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

-- Granularity is user-cirriculum class
CREATE TABLE curriculum (
	cirriculum_id 		INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    username 			VARCHAR(255) NOT NULL,
    department 			VARCHAR(255) NOT NULL,
    class_number 		INT NOT NULL,
    take_year		 	INT,
    take_semester 		ENUM('SPRING', 'FALL', 'SUMMER'),
    FOREIGN KEY (username) REFERENCES user(username),
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

/*
Appointment Scheduling
======================
To schedule appointments, we simply have to track advisor availability and scheduled appoitments.
*/
CREATE TABLE advisor_availability (
	availability_id 	INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	advisor_username 	VARCHAR(255) NOT NULL,
    start_time 			TIMESTAMP,
    end_time 			TIMESTAMP,
    FOREIGN KEY (advisor_username) REFERENCES user(username)
);

CREATE TABLE scheduled_appointment (
	appointment INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    advisor_username 	VARCHAR(255) NOT NULL,
    student_username 	VARCHAR(255) NOT NULL,
    start_time 			TIMESTAMP,
    end_time 			TIMESTAMP,
    topic 				VARCHAR(2047),
    FOREIGN KEY (advisor_username) REFERENCES user(username),
    FOREIGN KEY (student_username) REFERENCES user(username)
);

-- Admin user
INSERT INTO user VALUES ('admin', '', 'Team', 'Galactic', 0, 0, 'DialgaPalkia$13');

-- Insert dummy classes
-- MATH 1 -> 2 -> 3
-- STATS 1 requires MATH 1 -> STATS 2
-- CS 1 -> CS 2 -> CS 3 requires CS 2 AND MATH 2
-- CX 1 requires CS 1 AND (STATS 1 OR MATH 1)
-- CAPSTONE 1 requires (MATH 3 OR STATS 2) AND (CS 3 OR CX 1)

-- class
INSERT INTO class VALUES ('MATH', 1, 'INTRO MATH', 'Intro to math');
INSERT INTO class VALUES ('MATH', 2, 'INTER MATH', 'Intermediate math');
INSERT INTO class VALUES ('MATH', 3, 'ADVAN MATH', 'Advanced topics in math');

INSERT INTO class VALUES ('STATS', 1, 'INTRO STATS', 'Intro to statistics');
INSERT INTO class VALUES ('STATS', 2, 'INTER STATS', 'Intermediate statistics');

INSERT INTO class VALUES ('CS', 1, 'INTRO CS', 'Introduction to CS');
INSERT INTO class VALUES ('CS', 2, 'INTER CS', 'Intermediate CS');
INSERT INTO class VALUES ('CS', 3, 'ADVAN CS', 'Advanced topics in CS');

INSERT INTO class VALUES ('CX', 1, 'INTRO MODSIM', 'Intro to modeling and simulation');

INSERT INTO class VALUES ('CAPSTONE', 1, 'CAPSTONE', 'Capstone project');

-- when_classes_offered

-- class_list
INSERT INTO class_list VALUES (1, 'MATH1', 'MATH', 1);
INSERT INTO class_list VALUES (2, 'MATH2', 'MATH', 2);

INSERT INTO class_list VALUES (3, 'CS1', 'CS', 1);
INSERT INTO class_list VALUES (4, 'CS2', 'CS', 2);

INSERT INTO class_list VALUES (5, 'STATS1', 'STATS', 1);

INSERT INTO class_list VALUES (6, 'STATS1_MATH1', 'STATS', 1);
INSERT INTO class_list VALUES (7, 'STATS1_MATH1', 'MATH', 1);

INSERT INTO class_list VALUES (8, 'MATH3_STATS2', 'MATH', 3);
INSERT INTO class_list VALUES (9, 'MATH3_STATS2', 'STATS', 2);

INSERT INTO class_list VALUES (10, 'CS3_CX1', 'CS', 3);
INSERT INTO class_list VALUES (11, 'CS3_CX1', 'CX', 1);

-- class_prerequisite
INSERT INTO class_prerequisite VALUES (1, 'MATH', 2, 'MATH1');
INSERT INTO class_prerequisite VALUES (2, 'MATH', 3, 'MATH2');

INSERT INTO class_prerequisite VALUES (3, 'STATS', 1, 'MATH1');
INSERT INTO class_prerequisite VALUES (4, 'STATS', 2, 'STATS1');

INSERT INTO class_prerequisite VALUES (5, 'CS', 2, 'CS1');
INSERT INTO class_prerequisite VALUES (6, 'CS', 3, 'CS2');
INSERT INTO class_prerequisite VALUES (7, 'CS', 3, 'MATH2');

INSERT INTO class_prerequisite VALUES (8, 'CX', 1, 'CS1');
INSERT INTO class_prerequisite VALUES (9, 'CX', 1, 'STATS1_MATH1');

INSERT INTO class_prerequisite VALUES (10, 'CAPSTONE', 1, 'MATH3_STATS2');
INSERT INTO class_prerequisite VALUES (11, 'CAPSTONE', 1, 'CS3_CX1');

-- Insert dummy thread, requirements are:
-- MATH 1 and 2
-- 6 hours from STATS 2, CX 1, MATH 3
-- CS 1, 2, 3
-- CAPSTONE 1
-- 6 hours free electives

INSERT INTO thread VALUES ('Test Thread', 6);

INSERT INTO class_list VALUES (12, 'Test Thread Core', 'MATH', 1);
INSERT INTO class_list VALUES (13, 'Test Thread Core', 'MATH', 2);
INSERT INTO class_list VALUES (14, 'Test Thread Core', 'CS', 1);
INSERT INTO class_list VALUES (15, 'Test Thread Core', 'CS', 2);
INSERT INTO class_list VALUES (16, 'Test Thread Core', 'CS', 3);
INSERT INTO class_list VALUES (17, 'Test Thread Core', 'CAPSTONE', 1);

INSERT INTO class_list VALUES (18, 'Test Thread Math', 'STATS', 2);
INSERT INTO class_list VALUES (19, 'Test Thread Math', 'CX', 1);
INSERT INTO class_list VALUES (20, 'Test Thread Math', 'MATH', 3);

INSERT INTO thread_requirement VALUES (1, 'Test Thread', 'Test Thread Core', 18);
INSERT INTO thread_requirement VALUES (2, 'Test Thread', 'Test Thread Math', 6);


-- real classes
INSERT INTO class VALUES ('CS', 1100, 'CS1100', 'CS1100 description');
INSERT INTO class VALUES ('CS', 1171, 'CS1171', 'CS1171 description');
INSERT INTO class VALUES ('CS', 1301, 'CS1301', 'CS1301 description');
INSERT INTO class VALUES ('CS', 1315, 'CS1315', 'CS1315 description');
INSERT INTO class VALUES ('CS', 1316, 'CS1316', 'CS1316 description');
INSERT INTO class VALUES ('CS', 1331, 'CS1331', 'CS1331 description');
INSERT INTO class VALUES ('CS', 1332, 'CS1332', 'CS1332 description');
INSERT INTO class VALUES ('CS', 1371, 'CS1371', 'CS1371 description');
INSERT INTO class VALUES ('CS', 1372, 'CS1372', 'CS1372 description');
INSERT INTO class VALUES ('CS', 2050, 'CS2050', 'CS2050 description');
INSERT INTO class VALUES ('CS', 2051, 'CS2051', 'CS2051 description');
INSERT INTO class VALUES ('CS', 2110, 'CS2110', 'CS2110 description');
INSERT INTO class VALUES ('CS', 2200, 'CS2200', 'CS2200 description');
INSERT INTO class VALUES ('CS', 2261, 'CS2261', 'CS2261 description');
INSERT INTO class VALUES ('CS', 2316, 'CS2316', 'CS2316 description');
INSERT INTO class VALUES ('CS', 2335, 'CS2335', 'CS2335 description');
INSERT INTO class VALUES ('CS', 2340, 'CS2340', 'CS2340 description');
INSERT INTO class VALUES ('CS', 2345, 'CS2345', 'CS2345 description');
INSERT INTO class VALUES ('ECE', 2020, 'ECE2020', 'ECE2020 description');
INSERT INTO class VALUES ('ECE', 2035, 'ECE2035', 'ECE2035 description');
INSERT INTO class VALUES ('CS', 2600, 'CS2600', 'CS2600 description');
INSERT INTO class VALUES ('CS', 2701, 'CS2701', 'CS2701 description');
INSERT INTO class VALUES ('CS', 3101, 'CS3101', 'CS3101 description');
INSERT INTO class VALUES ('CS', 3210, 'CS3210', 'CS3210 description');
INSERT INTO class VALUES ('CS', 3220, 'CS3220', 'CS3220 description');
INSERT INTO class VALUES ('CS', 3240, 'CS3240', 'CS3240 description');
INSERT INTO class VALUES ('CS', 3251, 'CS3251', 'CS3251 description');
INSERT INTO class VALUES ('CS', 3300, 'CS3300', 'CS3300 description');
INSERT INTO class VALUES ('CS', 3311, 'CS3311', 'CS3311 description');
INSERT INTO class VALUES ('CS', 3312, 'CS3312', 'CS3312 description');
INSERT INTO class VALUES ('CS', 3451, 'CS3451', 'CS3451 description');
INSERT INTO class VALUES ('CS', 3510, 'CS3510', 'CS3510 description');
INSERT INTO class VALUES ('CS', 3511, 'CS3511', 'CS3511 description');
INSERT INTO class VALUES ('CS', 3600, 'CS3600', 'CS3600 description');
INSERT INTO class VALUES ('CS', 3630, 'CS3630', 'CS3630 description');
INSERT INTO class VALUES ('CS', 3651, 'CS3651', 'CS3651 description');
INSERT INTO class VALUES ('CS', 3743, 'CS3743', 'CS3743 description');
INSERT INTO class VALUES ('CS', 3744, 'CS3744', 'CS3744 description');
INSERT INTO class VALUES ('CS', 3750, 'CS3750', 'CS3750 description');
INSERT INTO class VALUES ('CS', 3790, 'CS3790', 'CS3790 description');
INSERT INTO class VALUES ('CS', 4001, 'CS4001', 'CS4001 description');
INSERT INTO class VALUES ('CS', 4002, 'CS4002', 'CS4002 description');
INSERT INTO class VALUES ('CS', 4005, 'CS4005', 'CS4005 description');
INSERT INTO class VALUES ('CS', 4010, 'CS4010', 'CS4010 description');
INSERT INTO class VALUES ('CS', 4052, 'CS4052', 'CS4052 description');
INSERT INTO class VALUES ('CS', 4057, 'CS4057', 'CS4057 description');
INSERT INTO class VALUES ('CS', 4210, 'CS4210', 'CS4210 description');
INSERT INTO class VALUES ('CS', 4220, 'CS4220', 'CS4220 description');
INSERT INTO class VALUES ('CS', 4233, 'CS4233', 'CS4233 description');
INSERT INTO class VALUES ('CS', 4235, 'CS4235', 'CS4235 description');
INSERT INTO class VALUES ('CS', 4237, 'CS4237', 'CS4237 description');
INSERT INTO class VALUES ('CS', 4240, 'CS4240', 'CS4240 description');
INSERT INTO class VALUES ('CS', 4245, 'CS4245', 'CS4245 description');
INSERT INTO class VALUES ('CS', 4251, 'CS4251', 'CS4251 description');
INSERT INTO class VALUES ('CS', 4255, 'CS4255', 'CS4255 description');
INSERT INTO class VALUES ('CS', 4260, 'CS4260', 'CS4260 description');
INSERT INTO class VALUES ('CS', 4261, 'CS4261', 'CS4261 description');
INSERT INTO class VALUES ('CS', 4270, 'CS4270', 'CS4270 description');
INSERT INTO class VALUES ('CS', 4280, 'CS4280', 'CS4280 description');
INSERT INTO class VALUES ('CS', 4290, 'CS4290', 'CS4290 description');
INSERT INTO class VALUES ('CS', 4320, 'CS4320', 'CS4320 description');
INSERT INTO class VALUES ('CS', 4330, 'CS4330', 'CS4330 description');
INSERT INTO class VALUES ('CS', 4342, 'CS4342', 'CS4342 description');
INSERT INTO class VALUES ('CS', 4365, 'CS4365', 'CS4365 description');
INSERT INTO class VALUES ('CS', 4392, 'CS4392', 'CS4392 description');
INSERT INTO class VALUES ('CS', 4400, 'CS4400', 'CS4400 description');
INSERT INTO class VALUES ('CS', 4420, 'CS4420', 'CS4420 description');
INSERT INTO class VALUES ('CS', 4432, 'CS4432', 'CS4432 description');
INSERT INTO class VALUES ('CS', 4440, 'CS4440', 'CS4440 description');
INSERT INTO class VALUES ('CS', 4452, 'CS4452', 'CS4452 description');
INSERT INTO class VALUES ('CS', 4455, 'CS4455', 'CS4455 description');
INSERT INTO class VALUES ('CS', 4460, 'CS4460', 'CS4460 description');
INSERT INTO class VALUES ('CS', 4464, 'CS4464', 'CS4464 description');
INSERT INTO class VALUES ('CS', 4470, 'CS4470', 'CS4470 description');
INSERT INTO class VALUES ('CS', 4472, 'CS4472', 'CS4472 description');
INSERT INTO class VALUES ('CS', 4475, 'CS4475', 'CS4475 description');
INSERT INTO class VALUES ('CS', 4476, 'CS4476', 'CS4476 description');
INSERT INTO class VALUES ('CS', 4480, 'CS4480', 'CS4480 description');
INSERT INTO class VALUES ('CS', 4495, 'CS4495', 'CS4495 description');
INSERT INTO class VALUES ('CS', 4496, 'CS4496', 'CS4496 description');
INSERT INTO class VALUES ('CS', 4497, 'CS4497', 'CS4497 description');
INSERT INTO class VALUES ('ISYE', 2028, 'ISYE2028', 'ISYE2028 description');
INSERT INTO class VALUES ('CS', 4510, 'CS4510', 'CS4510 description');
INSERT INTO class VALUES ('CS', 4520, 'CS4520', 'CS4520 description');
INSERT INTO class VALUES ('CS', 4530, 'CS4530', 'CS4530 description');
INSERT INTO class VALUES ('CS', 4540, 'CS4540', 'CS4540 description');
INSERT INTO class VALUES ('CS', 4550, 'CS4550', 'CS4550 description');
INSERT INTO class VALUES ('CS', 4560, 'CS4560', 'CS4560 description');
INSERT INTO class VALUES ('CS', 4590, 'CS4590', 'CS4590 description');
INSERT INTO class VALUES ('CS', 4605, 'CS4605', 'CS4605 description');
INSERT INTO class VALUES ('CS', 4611, 'CS4611', 'CS4611 description');
INSERT INTO class VALUES ('CS', 4613, 'CS4613', 'CS4613 description');
INSERT INTO class VALUES ('CS', 4615, 'CS4615', 'CS4615 description');
INSERT INTO class VALUES ('CS', 4616, 'CS4616', 'CS4616 description');
INSERT INTO class VALUES ('CS', 4622, 'CS4622', 'CS4622 description');
INSERT INTO class VALUES ('CS', 4625, 'CS4625', 'CS4625 description');
INSERT INTO class VALUES ('CS', 4632, 'CS4632', 'CS4632 description');
INSERT INTO class VALUES ('CS', 4635, 'CS4635', 'CS4635 description');
INSERT INTO class VALUES ('CS', 4641, 'CS4641', 'CS4641 description');
INSERT INTO class VALUES ('CS', 4646, 'CS4646', 'CS4646 description');
INSERT INTO class VALUES ('CS', 4649, 'CS4649', 'CS4649 description');
INSERT INTO class VALUES ('CS', 4650, 'CS4650', 'CS4650 description');
INSERT INTO class VALUES ('CS', 4660, 'CS4660', 'CS4660 description');
INSERT INTO class VALUES ('CS', 4665, 'CS4665', 'CS4665 description');
INSERT INTO class VALUES ('CS', 4670, 'CS4670', 'CS4670 description');
INSERT INTO class VALUES ('CS', 4675, 'CS4675', 'CS4675 description');
INSERT INTO class VALUES ('CS', 4685, 'CS4685', 'CS4685 description');
INSERT INTO class VALUES ('CS', 4690, 'CS4690', 'CS4690 description');
INSERT INTO class VALUES ('CS', 4710, 'CS4710', 'CS4710 description');
INSERT INTO class VALUES ('CS', 4725, 'CS4725', 'CS4725 description');
INSERT INTO class VALUES ('CS', 4726, 'CS4726', 'CS4726 description');
INSERT INTO class VALUES ('CS', 4731, 'CS4731', 'CS4731 description');
INSERT INTO class VALUES ('CS', 4741, 'CS4741', 'CS4741 description');
INSERT INTO class VALUES ('CS', 4742, 'CS4742', 'CS4742 description');
INSERT INTO class VALUES ('CS', 4745, 'CS4745', 'CS4745 description');
INSERT INTO class VALUES ('CS', 4752, 'CS4752', 'CS4752 description');
INSERT INTO class VALUES ('CS', 4770, 'CS4770', 'CS4770 description');
INSERT INTO class VALUES ('CS', 4791, 'CS4791', 'CS4791 description');
INSERT INTO class VALUES ('CS', 4792, 'CS4792', 'CS4792 description');
INSERT INTO class VALUES ('CS', 4793, 'CS4793', 'CS4793 description');
INSERT INTO class VALUES ('CS', 4795, 'CS4795', 'CS4795 description');
INSERT INTO class VALUES ('CS', 4911, 'CS4911', 'CS4911 description');
INSERT INTO class VALUES ('CS', 4912, 'CS4912', 'CS4912 description');
INSERT INTO class VALUES ('CX', 4010, 'CX4010', 'CX4010 description');
INSERT INTO class VALUES ('CX', 4140, 'CX4140', 'CX4140 description');
INSERT INTO class VALUES ('CX', 4220, 'CX4220', 'CX4220 description');
INSERT INTO class VALUES ('CX', 4230, 'CX4230', 'CX4230 description');
INSERT INTO class VALUES ('CX', 4232, 'CX4232', 'CX4232 description');
INSERT INTO class VALUES ('CX', 4236, 'CX4236', 'CX4236 description');
INSERT INTO class VALUES ('CX', 4240, 'CX4240', 'CX4240 description');
INSERT INTO class VALUES ('CX', 4242, 'CX4242', 'CX4242 description');
INSERT INTO class VALUES ('CX', 4640, 'CX4640', 'CX4640 description');
INSERT INTO class VALUES ('CX', 4641, 'CX4641', 'CX4641 description');
INSERT INTO class VALUES ('CX', 4777, 'CX4777', 'CX4777 description');
INSERT INTO class VALUES ('CS', 1321, 'CS1321', 'CS1321 description');
INSERT INTO class VALUES ('CS', 1322, 'CS1322', 'CS1322 description');
INSERT INTO class VALUES ('ECE', 3037, 'ECE3037', 'ECE3037 description');
INSERT INTO class VALUES ('ECE', 2031, 'ECE2031', 'ECE2031 description');
INSERT INTO class VALUES ('LMC', 3432, 'LMC3432', 'LMC3432 description');
INSERT INTO class VALUES ('MATH', 2605, 'MATH2605', 'MATH2605 description');
INSERT INTO class VALUES ('MATH', 2401, 'MATH2401', 'MATH2401 description');
INSERT INTO class VALUES ('MATH', 2411, 'MATH2411', 'MATH2411 description');
INSERT INTO class VALUES ('MATH', 2550, 'MATH2550', 'MATH2550 description');
INSERT INTO class VALUES ('MATH', 2551, 'MATH2551', 'MATH2551 description');
INSERT INTO class VALUES ('MATH', 2561, 'MATH2561', 'MATH2561 description');
INSERT INTO class VALUES ('CS2110,', 2261, 'CS2110,2261', 'CS2110,2261 description');
INSERT INTO class VALUES ('CS2050, CS', 2051, 'CS2050, CS2051', 'CS2050, CS2051 description');
INSERT INTO class VALUES ('MATH', 2106, 'MATH2106', 'MATH2106 description');
INSERT INTO class VALUES ('MATH', 3012, 'MATH3012', 'MATH3012 description');
INSERT INTO class VALUES ('MATH', 3022, 'MATH3022', 'MATH3022 description');
INSERT INTO class VALUES ('MGT', 2200, 'MGT2200', 'MGT2200 description');
INSERT INTO class VALUES ('MATH', 3215, 'MATH3215', 'MATH3215 description');
INSERT INTO class VALUES ('MATH', 3225, 'MATH3225', 'MATH3225 description');
INSERT INTO class VALUES ('MATH', 3770, 'MATH3770', 'MATH3770 description');
INSERT INTO class VALUES ('ISYE3770, CEE', 3770, 'ISYE3770, CEE3770', 'ISYE3770, CEE3770 description');
INSERT INTO class VALUES ('MATH', 3670, 'MATH3670', 'MATH3670 description');
INSERT INTO class VALUES ('PSYC', 3750, 'PSYC3750', 'PSYC3750 description');
INSERT INTO class VALUES ('MATH', 1553, 'MATH1553', 'MATH1553 description');
INSERT INTO class VALUES ('MATH', 1554, 'MATH1554', 'MATH1554 description');
INSERT INTO class VALUES ('MATH', 1564, 'MATH1564', 'MATH1564 description');
INSERT INTO class VALUES ('ISYE', 2027, 'ISYE2027', 'ISYE2027 description');
INSERT INTO class VALUES ('MATH', 3235, 'MATH3235', 'MATH3235 description');
INSERT INTO class VALUES ('ISYE', 3770, 'ISYE3770', 'ISYE3770 description');
INSERT INTO class VALUES ('CEE', 3770, 'CEE3770', 'CEE3770 description');
INSERT INTO class VALUES ('CS', 1050, 'CS1050', 'CS1050 description');
INSERT INTO class VALUES ('CS3510,', 3511, 'CS3510,3511', 'CS3510,3511 description');
INSERT INTO class VALUES ('LCC', 2700, 'LCC2700', 'LCC2700 description');
INSERT INTO class VALUES ('PST', 3790, 'PST3790', 'PST3790 description');
INSERT INTO class VALUES ('PSYC', 3790, 'PSYC3790', 'PSYC3790 description');
INSERT INTO class VALUES ('ISYE', 3790, 'ISYE3790', 'ISYE3790 description');
INSERT INTO class VALUES ('ECE', 2036, 'ECE2036', 'ECE2036 description');
INSERT INTO class VALUES ('BMED', 2400, 'BMED2400', 'BMED2400 description');
INSERT INTO class VALUES ('ECE', 3077, 'ECE3077', 'ECE3077 description');
INSERT INTO class VALUES ('ECE', 3770, 'ECE3770', 'ECE3770 description');
INSERT INTO class VALUES ('MATH', 2403, 'MATH2403', 'MATH2403 description');
INSERT INTO class VALUES ('MATH', 2413, 'MATH2413', 'MATH2413 description');
INSERT INTO class VALUES ('MATH', 2602, 'MATH2602', 'MATH2602 description');
INSERT INTO class VALUES ('MATH', 2603, 'MATH2603', 'MATH2603 description');
INSERT INTO class VALUES ('MATH', 2552, 'MATH2552', 'MATH2552 description');
INSERT INTO class VALUES ('MATH', 2562, 'MATH2562', 'MATH2562 description');
INSERT INTO class VALUES ('MATH', 4640, 'MATH4640', 'MATH4640 description');
INSERT INTO class_prerequisite VALUES (100, 'CS', 1100, 'CS1100_DEP1');
INSERT INTO class_list VALUES (100, 'CS1171_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (101, 'CS1171_DEP1', 'CS', 1315);
INSERT INTO class_prerequisite VALUES (101, 'CS', 1171, 'CS1171_DEP1');
INSERT INTO class_prerequisite VALUES (102, 'CS', 1301, 'CS1301_DEP1');
INSERT INTO class_prerequisite VALUES (103, 'CS', 1315, 'CS1315_DEP1');
INSERT INTO class_list VALUES (102, 'CS1316_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (103, 'CS1316_DEP1', 'CS', 1315);
INSERT INTO class_list VALUES (104, 'CS1316_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (104, 'CS', 1316, 'CS1316_DEP1');
INSERT INTO class_list VALUES (105, 'CS1331_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (106, 'CS1331_DEP1', 'CS', 1315);
INSERT INTO class_list VALUES (107, 'CS1331_DEP1', 'CS', 1321);
INSERT INTO class_list VALUES (108, 'CS1331_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (105, 'CS', 1331, 'CS1331_DEP1');
INSERT INTO class_list VALUES (109, 'CS1332_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (110, 'CS1332_DEP1', 'CS', 1322);
INSERT INTO class_prerequisite VALUES (106, 'CS', 1332, 'CS1332_DEP1');
INSERT INTO class_prerequisite VALUES (107, 'CS', 1371, 'CS1371_DEP1');
INSERT INTO class_list VALUES (111, 'CS1372_DEP1', 'CS', 1171);
INSERT INTO class_list VALUES (112, 'CS1372_DEP1', 'CS', 1371);
INSERT INTO class_list VALUES (113, 'CS1372_DEP1', 'CS', 1301);
INSERT INTO class_prerequisite VALUES (108, 'CS', 1372, 'CS1372_DEP1');
INSERT INTO class_prerequisite VALUES (109, 'CS', 2050, 'CS2050_DEP1');
INSERT INTO class_prerequisite VALUES (110, 'CS', 2051, 'CS2051_DEP1');
INSERT INTO class_list VALUES (114, 'CS2110_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (111, 'CS', 2110, 'CS2110_DEP1');
INSERT INTO class_list VALUES (115, 'CS2200_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (116, 'CS2200_DEP1', 'ECE', 2035);
INSERT INTO class_prerequisite VALUES (112, 'CS', 2200, 'CS2200_DEP1');
INSERT INTO class_list VALUES (117, 'CS2261_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (113, 'CS', 2261, 'CS2261_DEP1');
INSERT INTO class_list VALUES (118, 'CS2316_DEP1', 'CS', 1371);
INSERT INTO class_list VALUES (119, 'CS2316_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (120, 'CS2316_DEP1', 'CS', 1315);
INSERT INTO class_prerequisite VALUES (114, 'CS', 2316, 'CS2316_DEP1');
INSERT INTO class_list VALUES (121, 'CS2335_DEP1', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (115, 'CS', 2335, 'CS2335_DEP1');
INSERT INTO class_list VALUES (122, 'CS2340_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (123, 'CS2340_DEP1', 'CS', 1372);
INSERT INTO class_list VALUES (124, 'CS2340_DEP1', 'CS', 1316);
INSERT INTO class_prerequisite VALUES (116, 'CS', 2340, 'CS2340_DEP1');
INSERT INTO class_list VALUES (125, 'CS2345_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (117, 'CS', 2345, 'CS2345_DEP1');
INSERT INTO class_list VALUES (126, 'CS2345_DEP2', 'CS', 2110);
INSERT INTO class_list VALUES (127, 'CS2345_DEP2', 'CS', 2261);
INSERT INTO class_list VALUES (128, 'CS2345_DEP2', 'ECE', 2035);
INSERT INTO class_prerequisite VALUES (118, 'CS', 2345, 'CS2345_DEP2');
INSERT INTO class_prerequisite VALUES (119, 'ECE', 2020, 'ECE2020_DEP1');
INSERT INTO class_list VALUES (129, 'ECE2035_DEP1', 'ECE', 2020);
INSERT INTO class_prerequisite VALUES (120, 'ECE', 2035, 'ECE2035_DEP1');
INSERT INTO class_list VALUES (130, 'CS2600_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (131, 'CS2600_DEP1', 'CS', 1315);
INSERT INTO class_list VALUES (132, 'CS2600_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (121, 'CS', 2600, 'CS2600_DEP1');
INSERT INTO class_prerequisite VALUES (122, 'CS', 2701, 'CS2701_DEP1');
INSERT INTO class_list VALUES (133, 'CS3101_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (134, 'CS3101_DEP1', 'CS', 1315);
INSERT INTO class_list VALUES (135, 'CS3101_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (123, 'CS', 3101, 'CS3101_DEP1');
INSERT INTO class_list VALUES (136, 'CS3210_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (137, 'CS3210_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (124, 'CS', 3210, 'CS3210_DEP1');
INSERT INTO class_list VALUES (138, 'CS3220_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (139, 'CS3220_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (125, 'CS', 3220, 'CS3220_DEP1');
INSERT INTO class_list VALUES (140, 'CS3220_DEP2', 'ECE', 2031);
INSERT INTO class_prerequisite VALUES (126, 'CS', 3220, 'CS3220_DEP2');
INSERT INTO class_list VALUES (141, 'CS3240_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (127, 'CS', 3240, 'CS3240_DEP1');
INSERT INTO class_list VALUES (142, 'CS3251_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (143, 'CS3251_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (128, 'CS', 3251, 'CS3251_DEP1');
INSERT INTO class_list VALUES (144, 'CS3300_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (129, 'CS', 3300, 'CS3300_DEP1');
INSERT INTO class_list VALUES (145, 'CS3311_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (130, 'CS', 3311, 'CS3311_DEP1');
INSERT INTO class_list VALUES (146, 'CS3312_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (131, 'CS', 3312, 'CS3312_DEP1');
INSERT INTO class_list VALUES (147, 'CS3312_DEP2', 'LMC', 3432);
INSERT INTO class_prerequisite VALUES (132, 'CS', 3312, 'CS3312_DEP2');
INSERT INTO class_list VALUES (148, 'CS3451_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (149, 'CS3451_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (150, 'CS3451_DEP1', 'MATH', 2411);
INSERT INTO class_list VALUES (151, 'CS3451_DEP1', 'MATH', 2550);
INSERT INTO class_list VALUES (152, 'CS3451_DEP1', 'MATH', 2551);
INSERT INTO class_list VALUES (153, 'CS3451_DEP1', 'MATH', 2561);
INSERT INTO class_prerequisite VALUES (133, 'CS', 3451, 'CS3451_DEP1');
INSERT INTO class_list VALUES (154, 'CS3451_DEP2', 'CS2110,', 2261);
INSERT INTO class_list VALUES (155, 'CS3451_DEP2', 'ECE', 2035);
INSERT INTO class_prerequisite VALUES (134, 'CS', 3451, 'CS3451_DEP2');
INSERT INTO class_list VALUES (156, 'CS3451_DEP3', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (135, 'CS', 3451, 'CS3451_DEP3');
INSERT INTO class_list VALUES (157, 'CS3451_DEP4', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (136, 'CS', 3451, 'CS3451_DEP4');
INSERT INTO class_list VALUES (158, 'CS3510_DEP1', 'CS2050, CS', 2051);
INSERT INTO class_list VALUES (159, 'CS3510_DEP1', 'MATH', 2106);
INSERT INTO class_prerequisite VALUES (137, 'CS', 3510, 'CS3510_DEP1');
INSERT INTO class_list VALUES (160, 'CS3510_DEP2', 'MATH', 3012);
INSERT INTO class_list VALUES (161, 'CS3510_DEP2', 'MATH', 3022);
INSERT INTO class_list VALUES (162, 'CS3510_DEP2', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (138, 'CS', 3510, 'CS3510_DEP2');
INSERT INTO class_list VALUES (163, 'CS3511_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (164, 'CS3511_DEP1', 'CS', 2051);
INSERT INTO class_list VALUES (165, 'CS3511_DEP1', 'MATH', 2106);
INSERT INTO class_prerequisite VALUES (139, 'CS', 3511, 'CS3511_DEP1');
INSERT INTO class_list VALUES (166, 'CS3511_DEP2', 'MATH', 3012);
INSERT INTO class_list VALUES (167, 'CS3511_DEP2', 'MATH', 3022);
INSERT INTO class_list VALUES (168, 'CS3511_DEP2', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (140, 'CS', 3511, 'CS3511_DEP2');
INSERT INTO class_list VALUES (169, 'CS3600_DEP1', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (141, 'CS', 3600, 'CS3600_DEP1');
INSERT INTO class_list VALUES (170, 'CS3630_DEP1', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (142, 'CS', 3630, 'CS3630_DEP1');
INSERT INTO class_list VALUES (171, 'CS3651_DEP1', 'ECE', 2031);
INSERT INTO class_prerequisite VALUES (143, 'CS', 3651, 'CS3651_DEP1');
INSERT INTO class_prerequisite VALUES (144, 'CS', 3743, 'CS3743_DEP1');
INSERT INTO class_prerequisite VALUES (145, 'CS', 3744, 'CS3744_DEP1');
INSERT INTO class_prerequisite VALUES (146, 'CS', 3750, 'CS3750_DEP1');
INSERT INTO class_prerequisite VALUES (147, 'CS', 3790, 'CS3790_DEP1');
INSERT INTO class_prerequisite VALUES (148, 'CS', 4001, 'CS4001_DEP1');
INSERT INTO class_prerequisite VALUES (149, 'CS', 4002, 'CS4002_DEP1');
INSERT INTO class_list VALUES (172, 'CS4005_DEP1', 'CS', 2316);
INSERT INTO class_prerequisite VALUES (150, 'CS', 4005, 'CS4005_DEP1');
INSERT INTO class_prerequisite VALUES (151, 'CS', 4010, 'CS4010_DEP1');
INSERT INTO class_prerequisite VALUES (152, 'CS', 4052, 'CS4052_DEP1');
INSERT INTO class_list VALUES (173, 'CS4057_DEP1', 'MGT', 2200);
INSERT INTO class_prerequisite VALUES (153, 'CS', 4057, 'CS4057_DEP1');
INSERT INTO class_list VALUES (174, 'CS4210_DEP1', 'CS', 3210);
INSERT INTO class_prerequisite VALUES (154, 'CS', 4210, 'CS4210_DEP1');
INSERT INTO class_list VALUES (175, 'CS4220_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (176, 'CS4220_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (155, 'CS', 4220, 'CS4220_DEP1');
INSERT INTO class_list VALUES (177, 'CS4233_DEP1', 'CS', 3210);
INSERT INTO class_prerequisite VALUES (156, 'CS', 4233, 'CS4233_DEP1');
INSERT INTO class_list VALUES (178, 'CS4235_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (179, 'CS4235_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (157, 'CS', 4235, 'CS4235_DEP1');
INSERT INTO class_list VALUES (180, 'CS4237_DEP1', 'CS', 3251);
INSERT INTO class_prerequisite VALUES (158, 'CS', 4237, 'CS4237_DEP1');
INSERT INTO class_list VALUES (181, 'CS4240_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (159, 'CS', 4240, 'CS4240_DEP1');
INSERT INTO class_list VALUES (182, 'CS4245_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (183, 'CS4245_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (184, 'CS4245_DEP1', 'MATH', 2411);
INSERT INTO class_prerequisite VALUES (160, 'CS', 4245, 'CS4245_DEP1');
INSERT INTO class_list VALUES (185, 'CS4245_DEP2', 'CS', 1332);
INSERT INTO class_list VALUES (186, 'CS4245_DEP2', 'CS', 1372);
INSERT INTO class_prerequisite VALUES (161, 'CS', 4245, 'CS4245_DEP2');
INSERT INTO class_list VALUES (187, 'CS4251_DEP1', 'CS', 3251);
INSERT INTO class_prerequisite VALUES (162, 'CS', 4251, 'CS4251_DEP1');
INSERT INTO class_list VALUES (188, 'CS4255_DEP1', 'CS', 3251);
INSERT INTO class_prerequisite VALUES (163, 'CS', 4255, 'CS4255_DEP1');
INSERT INTO class_list VALUES (189, 'CS4260_DEP1', 'MATH', 3215);
INSERT INTO class_list VALUES (190, 'CS4260_DEP1', 'MATH', 3225);
INSERT INTO class_list VALUES (191, 'CS4260_DEP1', 'MATH', 3770);
INSERT INTO class_list VALUES (192, 'CS4260_DEP1', 'ISYE3770, CEE', 3770);
INSERT INTO class_list VALUES (193, 'CS4260_DEP1', 'ISYE', 2028);
INSERT INTO class_list VALUES (194, 'CS4260_DEP1', 'MATH', 3670);
INSERT INTO class_prerequisite VALUES (164, 'CS', 4260, 'CS4260_DEP1');
INSERT INTO class_list VALUES (195, 'CS4260_DEP2', 'CS', 2200);
INSERT INTO class_prerequisite VALUES (165, 'CS', 4260, 'CS4260_DEP2');
INSERT INTO class_list VALUES (196, 'CS4261_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (197, 'CS4261_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (166, 'CS', 4261, 'CS4261_DEP1');
INSERT INTO class_list VALUES (198, 'CS4270_DEP1', 'CS', 3251);
INSERT INTO class_prerequisite VALUES (167, 'CS', 4270, 'CS4270_DEP1');
INSERT INTO class_prerequisite VALUES (168, 'CS', 4280, 'CS4280_DEP1');
INSERT INTO class_list VALUES (199, 'CS4290_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (200, 'CS4290_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (169, 'CS', 4290, 'CS4290_DEP1');
INSERT INTO class_list VALUES (201, 'CS4320_DEP1', 'CS', 3300);
INSERT INTO class_prerequisite VALUES (170, 'CS', 4320, 'CS4320_DEP1');
INSERT INTO class_list VALUES (202, 'CS4330_DEP1', 'CS', 3300);
INSERT INTO class_prerequisite VALUES (171, 'CS', 4330, 'CS4330_DEP1');
INSERT INTO class_list VALUES (203, 'CS4342_DEP1', 'CS', 3300);
INSERT INTO class_prerequisite VALUES (172, 'CS', 4342, 'CS4342_DEP1');
INSERT INTO class_list VALUES (204, 'CS4365_DEP1', 'CS', 3210);
INSERT INTO class_list VALUES (205, 'CS4365_DEP1', 'CS', 4400);
INSERT INTO class_prerequisite VALUES (173, 'CS', 4365, 'CS4365_DEP1');
INSERT INTO class_list VALUES (206, 'CS4392_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (174, 'CS', 4392, 'CS4392_DEP1');
INSERT INTO class_list VALUES (207, 'CS4400_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (208, 'CS4400_DEP1', 'CS', 1371);
INSERT INTO class_list VALUES (209, 'CS4400_DEP1', 'CS', 1315);
INSERT INTO class_prerequisite VALUES (175, 'CS', 4400, 'CS4400_DEP1');
INSERT INTO class_list VALUES (210, 'CS4420_DEP1', 'CS', 4400);
INSERT INTO class_prerequisite VALUES (176, 'CS', 4420, 'CS4420_DEP1');
INSERT INTO class_list VALUES (211, 'CS4432_DEP1', 'CS', 3300);
INSERT INTO class_list VALUES (212, 'CS4432_DEP1', 'CS', 4400);
INSERT INTO class_prerequisite VALUES (177, 'CS', 4432, 'CS4432_DEP1');
INSERT INTO class_list VALUES (213, 'CS4440_DEP1', 'CS', 4400);
INSERT INTO class_prerequisite VALUES (178, 'CS', 4440, 'CS4440_DEP1');
INSERT INTO class_prerequisite VALUES (179, 'CS', 4452, 'CS4452_DEP1');
INSERT INTO class_list VALUES (214, 'CS4455_DEP1', 'CS', 3451);
INSERT INTO class_prerequisite VALUES (180, 'CS', 4455, 'CS4455_DEP1');
INSERT INTO class_list VALUES (215, 'CS4460_DEP1', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (181, 'CS', 4460, 'CS4460_DEP1');
INSERT INTO class_list VALUES (216, 'CS4464_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (182, 'CS', 4464, 'CS4464_DEP1');
INSERT INTO class_list VALUES (217, 'CS4470_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (183, 'CS', 4470, 'CS4470_DEP1');
INSERT INTO class_list VALUES (218, 'CS4470_DEP2', 'CS', 3750);
INSERT INTO class_list VALUES (219, 'CS4470_DEP2', 'PSYC', 3750);
INSERT INTO class_prerequisite VALUES (184, 'CS', 4470, 'CS4470_DEP2');
INSERT INTO class_prerequisite VALUES (185, 'CS', 4472, 'CS4472_DEP1');
INSERT INTO class_list VALUES (220, 'CS4475_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (221, 'CS4475_DEP1', 'CS', 1315);
INSERT INTO class_list VALUES (222, 'CS4475_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (186, 'CS', 4475, 'CS4475_DEP1');
INSERT INTO class_list VALUES (223, 'CS4476_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (224, 'CS4476_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (225, 'CS4476_DEP1', 'MATH', 2411);
INSERT INTO class_list VALUES (226, 'CS4476_DEP1', 'MATH', 1553);
INSERT INTO class_list VALUES (227, 'CS4476_DEP1', 'MATH', 1554);
INSERT INTO class_list VALUES (228, 'CS4476_DEP1', 'MATH', 1564);
INSERT INTO class_prerequisite VALUES (187, 'CS', 4476, 'CS4476_DEP1');
INSERT INTO class_list VALUES (229, 'CS4476_DEP2', 'CS', 2110);
INSERT INTO class_list VALUES (230, 'CS4476_DEP2', 'CS', 2261);
INSERT INTO class_list VALUES (231, 'CS4476_DEP2', 'ECE', 2035);
INSERT INTO class_prerequisite VALUES (188, 'CS', 4476, 'CS4476_DEP2');
INSERT INTO class_list VALUES (232, 'CS4480_DEP1', 'CS', 3451);
INSERT INTO class_prerequisite VALUES (189, 'CS', 4480, 'CS4480_DEP1');
INSERT INTO class_list VALUES (233, 'CS4495_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (234, 'CS4495_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (235, 'CS4495_DEP1', 'MATH', 2411);
INSERT INTO class_prerequisite VALUES (190, 'CS', 4495, 'CS4495_DEP1');
INSERT INTO class_list VALUES (236, 'CS4495_DEP2', 'CS', 2110);
INSERT INTO class_list VALUES (237, 'CS4495_DEP2', 'CS', 2261);
INSERT INTO class_prerequisite VALUES (191, 'CS', 4495, 'CS4495_DEP2');
INSERT INTO class_list VALUES (238, 'CS4496_DEP1', 'CS', 3451);
INSERT INTO class_prerequisite VALUES (192, 'CS', 4496, 'CS4496_DEP1');
INSERT INTO class_list VALUES (239, 'CS4497_DEP1', 'CS', 3451);
INSERT INTO class_prerequisite VALUES (193, 'CS', 4497, 'CS4497_DEP1');
INSERT INTO class_list VALUES (240, 'ISYE2028_DEP1', 'ISYE', 2027);
INSERT INTO class_prerequisite VALUES (194, 'ISYE', 2028, 'ISYE2028_DEP1');
INSERT INTO class_list VALUES (241, 'CS4510_DEP1', 'MATH', 3012);
INSERT INTO class_list VALUES (242, 'CS4510_DEP1', 'MATH', 3022);
INSERT INTO class_prerequisite VALUES (195, 'CS', 4510, 'CS4510_DEP1');
INSERT INTO class_list VALUES (243, 'CS4510_DEP2', 'MATH', 3215);
INSERT INTO class_list VALUES (244, 'CS4510_DEP2', 'MATH', 3225);
INSERT INTO class_list VALUES (245, 'CS4510_DEP2', 'MATH', 3670);
INSERT INTO class_list VALUES (246, 'CS4510_DEP2', 'MATH', 3235);
INSERT INTO class_list VALUES (247, 'CS4510_DEP2', 'ISYE3770, CEE', 3770);
INSERT INTO class_list VALUES (248, 'CS4510_DEP2', 'ISYE', 2028);
INSERT INTO class_prerequisite VALUES (196, 'CS', 4510, 'CS4510_DEP2');
INSERT INTO class_list VALUES (249, 'CS4510_DEP3', 'CS', 3510);
INSERT INTO class_list VALUES (250, 'CS4510_DEP3', 'CS', 3511);
INSERT INTO class_prerequisite VALUES (197, 'CS', 4510, 'CS4510_DEP3');
INSERT INTO class_list VALUES (251, 'CS4520_DEP1', 'CS', 4540);
INSERT INTO class_prerequisite VALUES (198, 'CS', 4520, 'CS4520_DEP1');
INSERT INTO class_list VALUES (252, 'CS4530_DEP1', 'CS', 4540);
INSERT INTO class_prerequisite VALUES (199, 'CS', 4530, 'CS4530_DEP1');
INSERT INTO class_list VALUES (253, 'CS4540_DEP1', 'MATH', 3012);
INSERT INTO class_list VALUES (254, 'CS4540_DEP1', 'MATH', 3022);
INSERT INTO class_prerequisite VALUES (200, 'CS', 4540, 'CS4540_DEP1');
INSERT INTO class_list VALUES (255, 'CS4540_DEP2', 'MATH', 3215);
INSERT INTO class_list VALUES (256, 'CS4540_DEP2', 'MATH', 3225);
INSERT INTO class_list VALUES (257, 'CS4540_DEP2', 'MATH', 3670);
INSERT INTO class_list VALUES (258, 'CS4540_DEP2', 'MATH', 3235);
INSERT INTO class_list VALUES (259, 'CS4540_DEP2', 'ISYE', 3770);
INSERT INTO class_list VALUES (260, 'CS4540_DEP2', 'CEE', 3770);
INSERT INTO class_list VALUES (261, 'CS4540_DEP2', 'ISYE', 2028);
INSERT INTO class_prerequisite VALUES (201, 'CS', 4540, 'CS4540_DEP2');
INSERT INTO class_list VALUES (262, 'CS4540_DEP3', 'CS', 3510);
INSERT INTO class_list VALUES (263, 'CS4540_DEP3', 'CS', 3511);
INSERT INTO class_prerequisite VALUES (202, 'CS', 4540, 'CS4540_DEP3');
INSERT INTO class_list VALUES (264, 'CS4550_DEP1', 'CS', 3451);
INSERT INTO class_prerequisite VALUES (203, 'CS', 4550, 'CS4550_DEP1');
INSERT INTO class_list VALUES (265, 'CS4560_DEP1', 'CS', 1050);
INSERT INTO class_prerequisite VALUES (204, 'CS', 4560, 'CS4560_DEP1');
INSERT INTO class_list VALUES (266, 'CS4560_DEP2', 'CS', 3510);
INSERT INTO class_prerequisite VALUES (205, 'CS', 4560, 'CS4560_DEP2');
INSERT INTO class_prerequisite VALUES (206, 'CS', 4590, 'CS4590_DEP1');
INSERT INTO class_list VALUES (267, 'CS4605_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (268, 'CS4605_DEP1', 'CS', 2261);
INSERT INTO class_list VALUES (269, 'CS4605_DEP1', 'ECE', 2035);
INSERT INTO class_prerequisite VALUES (207, 'CS', 4605, 'CS4605_DEP1');
INSERT INTO class_list VALUES (270, 'CS4611_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (208, 'CS', 4611, 'CS4611_DEP1');
INSERT INTO class_list VALUES (271, 'CS4613_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (209, 'CS', 4613, 'CS4613_DEP1');
INSERT INTO class_list VALUES (272, 'CS4615_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (210, 'CS', 4615, 'CS4615_DEP1');
INSERT INTO class_list VALUES (273, 'CS4616_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (211, 'CS', 4616, 'CS4616_DEP1');
INSERT INTO class_list VALUES (274, 'CS4622_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (212, 'CS', 4622, 'CS4622_DEP1');
INSERT INTO class_list VALUES (275, 'CS4625_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (213, 'CS', 4625, 'CS4625_DEP1');
INSERT INTO class_list VALUES (276, 'CS4632_DEP1', 'CS', 3630);
INSERT INTO class_prerequisite VALUES (214, 'CS', 4632, 'CS4632_DEP1');
INSERT INTO class_list VALUES (277, 'CS4635_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (215, 'CS', 4635, 'CS4635_DEP1');
INSERT INTO class_list VALUES (278, 'CS4641_DEP1', 'CS', 1331);
INSERT INTO class_prerequisite VALUES (216, 'CS', 4641, 'CS4641_DEP1');
INSERT INTO class_list VALUES (279, 'CS4646_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (217, 'CS', 4646, 'CS4646_DEP1');
INSERT INTO class_list VALUES (280, 'CS4649_DEP1', 'CS', 1332);
INSERT INTO class_prerequisite VALUES (218, 'CS', 4649, 'CS4649_DEP1');
INSERT INTO class_list VALUES (281, 'CS4650_DEP1', 'CS3510,', 3511);
INSERT INTO class_prerequisite VALUES (219, 'CS', 4650, 'CS4650_DEP1');
INSERT INTO class_prerequisite VALUES (220, 'CS', 4660, 'CS4660_DEP1');
INSERT INTO class_list VALUES (282, 'CS4665_DEP1', 'CS', 4660);
INSERT INTO class_prerequisite VALUES (221, 'CS', 4665, 'CS4665_DEP1');
INSERT INTO class_list VALUES (283, 'CS4670_DEP1', 'CS', 4660);
INSERT INTO class_prerequisite VALUES (222, 'CS', 4670, 'CS4670_DEP1');
INSERT INTO class_list VALUES (284, 'CS4675_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (285, 'CS4675_DEP1', 'ECE', 3037);
INSERT INTO class_prerequisite VALUES (223, 'CS', 4675, 'CS4675_DEP1');
INSERT INTO class_list VALUES (286, 'CS4685_DEP1', 'CS', 2200);
INSERT INTO class_prerequisite VALUES (224, 'CS', 4685, 'CS4685_DEP1');
INSERT INTO class_list VALUES (287, 'CS4690_DEP1', 'CS', 3750);
INSERT INTO class_list VALUES (288, 'CS4690_DEP1', 'PSYC', 3750);
INSERT INTO class_prerequisite VALUES (225, 'CS', 4690, 'CS4690_DEP1');
INSERT INTO class_prerequisite VALUES (226, 'CS', 4710, 'CS4710_DEP1');
INSERT INTO class_prerequisite VALUES (227, 'CS', 4725, 'CS4725_DEP1');
INSERT INTO class_prerequisite VALUES (228, 'CS', 4726, 'CS4726_DEP1');
INSERT INTO class_list VALUES (289, 'CS4731_DEP1', 'CS', 3600);
INSERT INTO class_prerequisite VALUES (229, 'CS', 4731, 'CS4731_DEP1');
INSERT INTO class_prerequisite VALUES (230, 'CS', 4741, 'CS4741_DEP1');
INSERT INTO class_list VALUES (290, 'CS4742_DEP1', 'CS', 4741);
INSERT INTO class_prerequisite VALUES (231, 'CS', 4742, 'CS4742_DEP1');
INSERT INTO class_prerequisite VALUES (232, 'CS', 4745, 'CS4745_DEP1');
INSERT INTO class_prerequisite VALUES (233, 'CS', 4752, 'CS4752_DEP1');
INSERT INTO class_list VALUES (291, 'CS4770_DEP1', 'LCC', 2700);
INSERT INTO class_prerequisite VALUES (234, 'CS', 4770, 'CS4770_DEP1');
INSERT INTO class_list VALUES (292, 'CS4770_DEP2', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (235, 'CS', 4770, 'CS4770_DEP2');
INSERT INTO class_prerequisite VALUES (236, 'CS', 4791, 'CS4791_DEP1');
INSERT INTO class_prerequisite VALUES (237, 'CS', 4792, 'CS4792_DEP1');
INSERT INTO class_list VALUES (293, 'CS4793_DEP1', 'CS', 3790);
INSERT INTO class_list VALUES (294, 'CS4793_DEP1', 'PST', 3790);
INSERT INTO class_list VALUES (295, 'CS4793_DEP1', 'PSYC', 3790);
INSERT INTO class_list VALUES (296, 'CS4793_DEP1', 'ISYE', 3790);
INSERT INTO class_prerequisite VALUES (238, 'CS', 4793, 'CS4793_DEP1');
INSERT INTO class_list VALUES (297, 'CS4795_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (298, 'CS4795_DEP1', 'CS', 2261);
INSERT INTO class_list VALUES (299, 'CS4795_DEP1', 'ECE', 2035);
INSERT INTO class_list VALUES (300, 'CS4795_DEP1', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (239, 'CS', 4795, 'CS4795_DEP1');
INSERT INTO class_list VALUES (301, 'CS4911_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (240, 'CS', 4911, 'CS4911_DEP1');
INSERT INTO class_list VALUES (302, 'CS4912_DEP1', 'CS', 2340);
INSERT INTO class_prerequisite VALUES (241, 'CS', 4912, 'CS4912_DEP1');
INSERT INTO class_list VALUES (303, 'CX4010_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (304, 'CX4010_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (242, 'CX', 4010, 'CX4010_DEP1');
INSERT INTO class_list VALUES (305, 'CX4140_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (306, 'CX4140_DEP1', 'CS', 1372);
INSERT INTO class_list VALUES (307, 'CX4140_DEP1', 'CS', 2316);
INSERT INTO class_list VALUES (308, 'CX4140_DEP1', 'CX', 4010);
INSERT INTO class_list VALUES (309, 'CX4140_DEP1', 'ECE', 2035);
INSERT INTO class_list VALUES (310, 'CX4140_DEP1', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (243, 'CX', 4140, 'CX4140_DEP1');
INSERT INTO class_list VALUES (311, 'CX4220_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (312, 'CX4220_DEP1', 'CS', 1372);
INSERT INTO class_list VALUES (313, 'CX4220_DEP1', 'CS', 2316);
INSERT INTO class_list VALUES (314, 'CX4220_DEP1', 'CX', 4010);
INSERT INTO class_list VALUES (315, 'CX4220_DEP1', 'ECE', 2035);
INSERT INTO class_list VALUES (316, 'CX4220_DEP1', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (244, 'CX', 4220, 'CX4220_DEP1');
INSERT INTO class_list VALUES (317, 'CX4230_DEP1', 'MATH', 3215);
INSERT INTO class_list VALUES (318, 'CX4230_DEP1', 'MATH', 3225);
INSERT INTO class_list VALUES (319, 'CX4230_DEP1', 'MATH', 3670);
INSERT INTO class_list VALUES (320, 'CX4230_DEP1', 'MATH', 3770);
INSERT INTO class_list VALUES (321, 'CX4230_DEP1', 'ISYE', 3770);
INSERT INTO class_list VALUES (322, 'CX4230_DEP1', 'CEE', 3770);
INSERT INTO class_list VALUES (323, 'CX4230_DEP1', 'ISYE', 2028);
INSERT INTO class_list VALUES (324, 'CX4230_DEP1', 'BMED', 2400);
INSERT INTO class_list VALUES (325, 'CX4230_DEP1', 'ECE', 3077);
INSERT INTO class_prerequisite VALUES (245, 'CX', 4230, 'CX4230_DEP1');
INSERT INTO class_list VALUES (326, 'CX4230_DEP2', 'CS', 1331);
INSERT INTO class_list VALUES (327, 'CX4230_DEP2', 'CS', 1372);
INSERT INTO class_list VALUES (328, 'CX4230_DEP2', 'CS', 2316);
INSERT INTO class_list VALUES (329, 'CX4230_DEP2', 'CX', 4010);
INSERT INTO class_list VALUES (330, 'CX4230_DEP2', 'ECE', 2035);
INSERT INTO class_list VALUES (331, 'CX4230_DEP2', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (246, 'CX', 4230, 'CX4230_DEP2');
INSERT INTO class_list VALUES (332, 'CX4232_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (333, 'CX4232_DEP1', 'CS', 1372);
INSERT INTO class_list VALUES (334, 'CX4232_DEP1', 'CS', 2316);
INSERT INTO class_list VALUES (335, 'CX4232_DEP1', 'CX', 4010);
INSERT INTO class_list VALUES (336, 'CX4232_DEP1', 'ECE', 2035);
INSERT INTO class_list VALUES (337, 'CX4232_DEP1', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (247, 'CX', 4232, 'CX4232_DEP1');
INSERT INTO class_list VALUES (338, 'CX4236_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (339, 'CX4236_DEP1', 'CS', 1372);
INSERT INTO class_list VALUES (340, 'CX4236_DEP1', 'CS', 2316);
INSERT INTO class_list VALUES (341, 'CX4236_DEP1', 'CX', 4010);
INSERT INTO class_list VALUES (342, 'CX4236_DEP1', 'ECE', 2035);
INSERT INTO class_list VALUES (343, 'CX4236_DEP1', 'ECE', 2036);
INSERT INTO class_prerequisite VALUES (248, 'CX', 4236, 'CX4236_DEP1');
INSERT INTO class_list VALUES (344, 'CX4240_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (345, 'CX4240_DEP1', 'CS', 1371);
INSERT INTO class_prerequisite VALUES (249, 'CX', 4240, 'CX4240_DEP1');
INSERT INTO class_list VALUES (346, 'CX4242_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (347, 'CX4242_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (348, 'CX4242_DEP1', 'MATH', 2411);
INSERT INTO class_list VALUES (349, 'CX4242_DEP1', 'MATH', 2550);
INSERT INTO class_list VALUES (350, 'CX4242_DEP1', 'MATH', 2551);
INSERT INTO class_list VALUES (351, 'CX4242_DEP1', 'MATH', 2561);
INSERT INTO class_prerequisite VALUES (250, 'CX', 4242, 'CX4242_DEP1');
INSERT INTO class_list VALUES (352, 'CX4242_DEP2', 'MATH', 3215);
INSERT INTO class_list VALUES (353, 'CX4242_DEP2', 'MATH', 3225);
INSERT INTO class_list VALUES (354, 'CX4242_DEP2', 'MATH', 3670);
INSERT INTO class_list VALUES (355, 'CX4242_DEP2', 'MATH', 3770);
INSERT INTO class_list VALUES (356, 'CX4242_DEP2', 'ISYE', 3770);
INSERT INTO class_list VALUES (357, 'CX4242_DEP2', 'CEE', 3770);
INSERT INTO class_list VALUES (358, 'CX4242_DEP2', 'ISYE', 2028);
INSERT INTO class_list VALUES (359, 'CX4242_DEP2', 'BMED', 2400);
INSERT INTO class_list VALUES (360, 'CX4242_DEP2', 'ECE', 3770);
INSERT INTO class_prerequisite VALUES (251, 'CX', 4242, 'CX4242_DEP2');
INSERT INTO class_list VALUES (361, 'CX4242_DEP3', 'CS', 1331);
INSERT INTO class_list VALUES (362, 'CX4242_DEP3', 'CS', 1372);
INSERT INTO class_list VALUES (363, 'CX4242_DEP3', 'CS', 2316);
INSERT INTO class_list VALUES (364, 'CX4242_DEP3', 'CX', 4010);
INSERT INTO class_list VALUES (365, 'CX4242_DEP3', 'ECE', 2035);
INSERT INTO class_list VALUES (366, 'CX4242_DEP3', 'ECE', 2036);
INSERT INTO class_list VALUES (367, 'CX4242_DEP3', 'CX', 4240);
INSERT INTO class_prerequisite VALUES (252, 'CX', 4242, 'CX4242_DEP3');
INSERT INTO class_list VALUES (368, 'CX4640_DEP1', 'MATH', 2403);
INSERT INTO class_list VALUES (369, 'CX4640_DEP1', 'MATH', 2413);
INSERT INTO class_list VALUES (370, 'CX4640_DEP1', 'MATH', 2602);
INSERT INTO class_list VALUES (371, 'CX4640_DEP1', 'MATH', 2603);
INSERT INTO class_list VALUES (372, 'CX4640_DEP1', 'MATH', 2552);
INSERT INTO class_list VALUES (373, 'CX4640_DEP1', 'MATH', 2562);
INSERT INTO class_prerequisite VALUES (253, 'CX', 4640, 'CX4640_DEP1');
INSERT INTO class_list VALUES (374, 'CX4641_DEP1', 'CX', 4640);
INSERT INTO class_list VALUES (375, 'CX4641_DEP1', 'MATH', 4640);
INSERT INTO class_prerequisite VALUES (254, 'CX', 4641, 'CX4641_DEP1');
INSERT INTO class_list VALUES (376, 'CX4777_DEP1', 'MATH', 2605);
INSERT INTO class_list VALUES (377, 'CX4777_DEP1', 'MATH', 2401);
INSERT INTO class_list VALUES (378, 'CX4777_DEP1', 'MATH', 2411);
INSERT INTO class_list VALUES (379, 'CX4777_DEP1', 'MATH', 2550);
INSERT INTO class_list VALUES (380, 'CX4777_DEP1', 'MATH', 2551);
INSERT INTO class_list VALUES (381, 'CX4777_DEP1', 'MATH', 2561);
INSERT INTO class_prerequisite VALUES (255, 'CX', 4777, 'CX4777_DEP1');
INSERT INTO class_prerequisite VALUES (256, 'CS', 1321, 'CS1321_DEP1');
INSERT INTO class_prerequisite VALUES (257, 'CS', 1322, 'CS1322_DEP1');
INSERT INTO class_prerequisite VALUES (258, 'ECE', 3037, 'ECE3037_DEP1');
INSERT INTO class_prerequisite VALUES (259, 'ECE', 2031, 'ECE2031_DEP1');
INSERT INTO class_prerequisite VALUES (260, 'LMC', 3432, 'LMC3432_DEP1');
INSERT INTO class_prerequisite VALUES (261, 'MATH', 2605, 'MATH2605_DEP1');
INSERT INTO class_prerequisite VALUES (262, 'MATH', 2401, 'MATH2401_DEP1');
INSERT INTO class_prerequisite VALUES (263, 'MATH', 2411, 'MATH2411_DEP1');
INSERT INTO class_prerequisite VALUES (264, 'MATH', 2550, 'MATH2550_DEP1');
INSERT INTO class_prerequisite VALUES (265, 'MATH', 2551, 'MATH2551_DEP1');
INSERT INTO class_prerequisite VALUES (266, 'MATH', 2561, 'MATH2561_DEP1');
INSERT INTO class_prerequisite VALUES (267, 'CS2110,', 2261, 'CS2110,2261_DEP1');
INSERT INTO class_prerequisite VALUES (268, 'CS2050, CS', 2051, 'CS2050, CS2051_DEP1');
INSERT INTO class_prerequisite VALUES (269, 'MATH', 2106, 'MATH2106_DEP1');
INSERT INTO class_prerequisite VALUES (270, 'MATH', 3012, 'MATH3012_DEP1');
INSERT INTO class_prerequisite VALUES (271, 'MATH', 3022, 'MATH3022_DEP1');
INSERT INTO class_prerequisite VALUES (272, 'MGT', 2200, 'MGT2200_DEP1');
INSERT INTO class_prerequisite VALUES (273, 'MATH', 3215, 'MATH3215_DEP1');
INSERT INTO class_prerequisite VALUES (274, 'MATH', 3225, 'MATH3225_DEP1');
INSERT INTO class_prerequisite VALUES (275, 'MATH', 3770, 'MATH3770_DEP1');
INSERT INTO class_prerequisite VALUES (276, 'ISYE3770, CEE', 3770, 'ISYE3770, CEE3770_DEP1');
INSERT INTO class_prerequisite VALUES (277, 'MATH', 3670, 'MATH3670_DEP1');
INSERT INTO class_prerequisite VALUES (278, 'PSYC', 3750, 'PSYC3750_DEP1');
INSERT INTO class_prerequisite VALUES (279, 'MATH', 1553, 'MATH1553_DEP1');
INSERT INTO class_prerequisite VALUES (280, 'MATH', 1554, 'MATH1554_DEP1');
INSERT INTO class_prerequisite VALUES (281, 'MATH', 1564, 'MATH1564_DEP1');
INSERT INTO class_prerequisite VALUES (282, 'ISYE', 2027, 'ISYE2027_DEP1');
INSERT INTO class_prerequisite VALUES (283, 'MATH', 3235, 'MATH3235_DEP1');
INSERT INTO class_prerequisite VALUES (284, 'ISYE', 3770, 'ISYE3770_DEP1');
INSERT INTO class_prerequisite VALUES (285, 'CEE', 3770, 'CEE3770_DEP1');
INSERT INTO class_prerequisite VALUES (286, 'CS', 1050, 'CS1050_DEP1');
INSERT INTO class_prerequisite VALUES (287, 'CS3510,', 3511, 'CS3510,3511_DEP1');
INSERT INTO class_prerequisite VALUES (288, 'LCC', 2700, 'LCC2700_DEP1');
INSERT INTO class_prerequisite VALUES (289, 'PST', 3790, 'PST3790_DEP1');
INSERT INTO class_prerequisite VALUES (290, 'PSYC', 3790, 'PSYC3790_DEP1');
INSERT INTO class_prerequisite VALUES (291, 'ISYE', 3790, 'ISYE3790_DEP1');
INSERT INTO class_prerequisite VALUES (292, 'ECE', 2036, 'ECE2036_DEP1');
INSERT INTO class_prerequisite VALUES (293, 'BMED', 2400, 'BMED2400_DEP1');
INSERT INTO class_prerequisite VALUES (294, 'ECE', 3077, 'ECE3077_DEP1');
INSERT INTO class_prerequisite VALUES (295, 'ECE', 3770, 'ECE3770_DEP1');
INSERT INTO class_prerequisite VALUES (296, 'MATH', 2403, 'MATH2403_DEP1');
INSERT INTO class_prerequisite VALUES (297, 'MATH', 2413, 'MATH2413_DEP1');
INSERT INTO class_prerequisite VALUES (298, 'MATH', 2602, 'MATH2602_DEP1');
INSERT INTO class_prerequisite VALUES (299, 'MATH', 2603, 'MATH2603_DEP1');
INSERT INTO class_prerequisite VALUES (300, 'MATH', 2552, 'MATH2552_DEP1');
INSERT INTO class_prerequisite VALUES (301, 'MATH', 2562, 'MATH2562_DEP1');
INSERT INTO class_prerequisite VALUES (302, 'MATH', 4640, 'MATH4640_DEP1');

-- Threads



INSERT INTO thread VALUES ('core', 0);
INSERT INTO class VALUES ('ENGL', 1101, 'ENGL1101', 'ENGL1101 description');
INSERT INTO class_list VALUES (382, 'core_DEP1', 'ENGL', 1101);
INSERT INTO class VALUES ('ENGL', 1102, 'ENGL1102', 'ENGL1102 description');
INSERT INTO class_list VALUES (383, 'core_DEP1', 'ENGL', 1102);
INSERT INTO class VALUES ('HUMA', 0, 'HUMA', 'HUMA description');
INSERT INTO class_list VALUES (384, 'core_DEP1', 'HUMA', 0);
INSERT INTO class VALUES ('HUMB', 0, 'HUMB', 'HUMB description');
INSERT INTO class_list VALUES (385, 'core_DEP1', 'HUMB', 0);
INSERT INTO class VALUES ('SSA', 0, 'SSA', 'SSA description');
INSERT INTO class_list VALUES (386, 'core_DEP1', 'SSA', 0);
INSERT INTO class VALUES ('SSB', 0, 'SSB', 'SSB description');
INSERT INTO class_list VALUES (387, 'core_DEP1', 'SSB', 0);
INSERT INTO class VALUES ('SSC', 0, 'SSC', 'SSC description');
INSERT INTO class_list VALUES (388, 'core_DEP1', 'SSC', 0);
INSERT INTO class VALUES ('SSD', 0, 'SSD', 'SSD description');
INSERT INTO class_list VALUES (389, 'core_DEP1', 'SSD', 0);
INSERT INTO class VALUES ('LABA', 0, 'LABA', 'LABA description');
INSERT INTO class_list VALUES (390, 'core_DEP1', 'LABA', 0);
INSERT INTO class VALUES ('LABB', 0, 'LABB', 'LABB description');
INSERT INTO class_list VALUES (391, 'core_DEP1', 'LABB', 0);
INSERT INTO class VALUES ('LABC', 0, 'LABC', 'LABC description');
INSERT INTO class_list VALUES (392, 'core_DEP1', 'LABC', 0);
INSERT INTO class VALUES ('APPHA', 0, 'APPHA', 'APPHA description');
INSERT INTO class_list VALUES (393, 'core_DEP1', 'APPHA', 0);
INSERT INTO class VALUES ('MATH', 1551, 'MATH1551', 'MATH1551 description');
INSERT INTO class_list VALUES (394, 'core_DEP1', 'MATH', 1551);
INSERT INTO class VALUES ('MATH', 1552, 'MATH1552', 'MATH1552 description');
INSERT INTO class_list VALUES (395, 'core_DEP1', 'MATH', 1552);
INSERT INTO class_list VALUES (396, 'core_DEP1', 'MATH', 1554);
INSERT INTO class_list VALUES (397, 'core_DEP1', 'CS', 1100);
INSERT INTO class VALUES ('FREEA', 0, 'FREEA', 'FREEA description');
INSERT INTO class_list VALUES (398, 'core_DEP1', 'FREEA', 0);
INSERT INTO class VALUES ('FREEB', 0, 'FREEB', 'FREEB description');
INSERT INTO class_list VALUES (399, 'core_DEP1', 'FREEB', 0);
INSERT INTO class VALUES ('FREEC', 0, 'FREEC', 'FREEC description');
INSERT INTO class_list VALUES (400, 'core_DEP1', 'FREEC', 0);
INSERT INTO class VALUES ('FREED', 0, 'FREED', 'FREED description');
INSERT INTO class_list VALUES (401, 'core_DEP1', 'FREED', 0);
INSERT INTO thread_requirement VALUES (100, 'core', 'core_DEP1', -1);
INSERT INTO thread VALUES ('info', 0);
INSERT INTO class_list VALUES (402, 'info_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (403, 'info_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (404, 'info_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (405, 'info_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (406, 'info_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (407, 'info_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (408, 'info_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (409, 'info_DEP1', 'CS', 3510);
INSERT INTO thread_requirement VALUES (101, 'info', 'info_DEP1', -1);
INSERT INTO class_list VALUES (410, 'info_DEP2', 'CS', 3251);
INSERT INTO class_list VALUES (411, 'info_DEP2', 'CS', 4235);
INSERT INTO class_list VALUES (412, 'info_DEP2', 'CS', 4400);
INSERT INTO thread_requirement VALUES (102, 'info', 'info_DEP2', 6);
INSERT INTO class_list VALUES (413, 'info_DEP3', 'CS', 4237);
INSERT INTO class_list VALUES (414, 'info_DEP3', 'CS', 4251);
INSERT INTO class_list VALUES (415, 'info_DEP3', 'CS', 4255);
INSERT INTO class_list VALUES (416, 'info_DEP3', 'CS', 4261);
INSERT INTO class_list VALUES (417, 'info_DEP3', 'CS', 4270);
INSERT INTO class_list VALUES (418, 'info_DEP3', 'CS', 4365);
INSERT INTO class_list VALUES (419, 'info_DEP3', 'CS', 4420);
INSERT INTO class_list VALUES (420, 'info_DEP3', 'CS', 4440);
INSERT INTO class_list VALUES (421, 'info_DEP3', 'CS', 4675);
INSERT INTO thread_requirement VALUES (103, 'info', 'info_DEP3', 3);
INSERT INTO thread VALUES ('devices', 0);
INSERT INTO class_list VALUES (422, 'devices_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (423, 'devices_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (424, 'devices_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (425, 'devices_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (426, 'devices_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (427, 'devices_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (428, 'devices_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (429, 'devices_DEP1', 'CS', 3251);
INSERT INTO class_list VALUES (430, 'devices_DEP1', 'ECE', 2031);
INSERT INTO thread_requirement VALUES (104, 'devices', 'devices_DEP1', -1);
INSERT INTO class_list VALUES (431, 'devices_DEP2', 'CS', 3240);
INSERT INTO class_list VALUES (432, 'devices_DEP2', 'CS', 3510);
INSERT INTO thread_requirement VALUES (105, 'devices', 'devices_DEP2', -1);
INSERT INTO class_list VALUES (433, 'devices_DEP3', 'CS', 3651);
INSERT INTO class VALUES ('ECE', 4180, 'ECE4180', 'ECE4180 description');
INSERT INTO class_list VALUES (434, 'devices_DEP3', 'ECE', 4180);
INSERT INTO thread_requirement VALUES (106, 'devices', 'devices_DEP3', 3);
INSERT INTO class_list VALUES (435, 'devices_DEP4', 'CS', 3630);
INSERT INTO class_list VALUES (436, 'devices_DEP4', 'CS', 4261);
INSERT INTO class_list VALUES (437, 'devices_DEP4', 'CS', 4476);
INSERT INTO class_list VALUES (438, 'devices_DEP4', 'CS', 4605);
INSERT INTO thread_requirement VALUES (107, 'devices', 'devices_DEP4', 3);
INSERT INTO thread VALUES ('intelligence', 0);
INSERT INTO class_list VALUES (439, 'intelligence_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (440, 'intelligence_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (441, 'intelligence_DEP1', 'CS', 1332);
INSERT INTO class VALUES ('PSYC', 1101, 'PSYC1101', 'PSYC1101 description');
INSERT INTO class_list VALUES (442, 'intelligence_DEP1', 'PSYC', 1101);
INSERT INTO class_list VALUES (443, 'intelligence_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (444, 'intelligence_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (445, 'intelligence_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (446, 'intelligence_DEP1', 'CS', 3510);
INSERT INTO class_list VALUES (447, 'intelligence_DEP1', 'CS', 3600);
INSERT INTO thread_requirement VALUES (108, 'intelligence', 'intelligence_DEP1', -1);
INSERT INTO class_list VALUES (448, 'intelligence_DEP2', 'CS', 4510);
INSERT INTO thread_requirement VALUES (109, 'intelligence', 'intelligence_DEP2', 3);
INSERT INTO class_list VALUES (449, 'intelligence_DEP3', 'CS', 3630);
INSERT INTO class_list VALUES (450, 'intelligence_DEP3', 'CS', 3790);
INSERT INTO class VALUES ('PSY', 3040, 'PSY3040', 'PSY3040 description');
INSERT INTO class_list VALUES (451, 'intelligence_DEP3', 'PSY', 3040);
INSERT INTO thread_requirement VALUES (110, 'intelligence', 'intelligence_DEP3', 3);
INSERT INTO class_list VALUES (452, 'intelligence_DEP4', 'CS', 4476);
INSERT INTO class_list VALUES (453, 'intelligence_DEP4', 'CS', 4635);
INSERT INTO class_list VALUES (454, 'intelligence_DEP4', 'CS', 4641);
INSERT INTO class_list VALUES (455, 'intelligence_DEP4', 'CS', 4646);
INSERT INTO class_list VALUES (456, 'intelligence_DEP4', 'CS', 4649);
INSERT INTO class_list VALUES (457, 'intelligence_DEP4', 'CS', 4650);
INSERT INTO class_list VALUES (458, 'intelligence_DEP4', 'CS', 4731);
INSERT INTO thread_requirement VALUES (111, 'intelligence', 'intelligence_DEP4', 6);
INSERT INTO thread VALUES ('media', 0);
INSERT INTO class_list VALUES (459, 'media_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (460, 'media_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (461, 'media_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (462, 'media_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (463, 'media_DEP1', 'CS', 2261);
INSERT INTO class_list VALUES (464, 'media_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (465, 'media_DEP1', 'CS', 3451);
INSERT INTO thread_requirement VALUES (112, 'media', 'media_DEP1', -1);
INSERT INTO class_list VALUES (466, 'media_DEP2', 'CS', 4455);
INSERT INTO class_list VALUES (467, 'media_DEP2', 'CS', 4460);
INSERT INTO class_list VALUES (468, 'media_DEP2', 'CS', 4464);
INSERT INTO class_list VALUES (469, 'media_DEP2', 'CS', 4475);
INSERT INTO class_list VALUES (470, 'media_DEP2', 'CS', 4497);
INSERT INTO class_list VALUES (471, 'media_DEP2', 'CS', 4480);
INSERT INTO class_list VALUES (472, 'media_DEP2', 'CS', 4496);
INSERT INTO class_list VALUES (473, 'media_DEP2', 'CS', 4590);
INSERT INTO thread_requirement VALUES (113, 'media', 'media_DEP2', 6);
INSERT INTO thread VALUES ('modsim', 0);
INSERT INTO class_list VALUES (474, 'modsim_DEP1', 'CS', 1171);
INSERT INTO class_list VALUES (475, 'modsim_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (476, 'modsim_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (477, 'modsim_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (478, 'modsim_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (479, 'modsim_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (480, 'modsim_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (481, 'modsim_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (482, 'modsim_DEP1', 'CS', 3510);
INSERT INTO class_list VALUES (483, 'modsim_DEP1', 'MATH', 2552);
INSERT INTO thread_requirement VALUES (114, 'modsim', 'modsim_DEP1', -1);
INSERT INTO class_list VALUES (484, 'modsim_DEP2', 'CX', 4140);
INSERT INTO class_list VALUES (485, 'modsim_DEP2', 'CX', 4220);
INSERT INTO class_list VALUES (486, 'modsim_DEP2', 'CX', 4230);
INSERT INTO class_list VALUES (487, 'modsim_DEP2', 'CX', 4640);
INSERT INTO class_list VALUES (488, 'modsim_DEP2', 'CS', 4641);
INSERT INTO thread_requirement VALUES (115, 'modsim', 'modsim_DEP2', 6);
INSERT INTO thread VALUES ('people', 0);
INSERT INTO class_list VALUES (489, 'people_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (490, 'people_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (491, 'people_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (492, 'people_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (493, 'people_DEP1', 'CS', 3750);
INSERT INTO class_list VALUES (494, 'people_DEP1', 'PSYC', 1101);
INSERT INTO class VALUES ('PSYC', 2015, 'PSYC2015', 'PSYC2015 description');
INSERT INTO class_list VALUES (495, 'people_DEP1', 'PSYC', 2015);
INSERT INTO thread_requirement VALUES (116, 'people', 'people_DEP1', -1);
INSERT INTO class VALUES ('PSYC', 2210, 'PSYC2210', 'PSYC2210 description');
INSERT INTO class_list VALUES (496, 'people_DEP2', 'PSYC', 2210);
INSERT INTO class VALUES ('PSYC', 2760, 'PSYC2760', 'PSYC2760 description');
INSERT INTO class_list VALUES (497, 'people_DEP2', 'PSYC', 2760);
INSERT INTO class VALUES ('PSYC', 3040, 'PSYC3040', 'PSYC3040 description');
INSERT INTO class_list VALUES (498, 'people_DEP2', 'PSYC', 3040);
INSERT INTO thread_requirement VALUES (117, 'people', 'people_DEP2', 3);
INSERT INTO class_list VALUES (499, 'people_DEP3', 'CS', 3790);
INSERT INTO class_list VALUES (500, 'people_DEP3', 'CS', 4460);
INSERT INTO class_list VALUES (501, 'people_DEP3', 'CS', 4470);
INSERT INTO class_list VALUES (502, 'people_DEP3', 'CS', 4472);
INSERT INTO class_list VALUES (503, 'people_DEP3', 'CS', 4605);
INSERT INTO class_list VALUES (504, 'people_DEP3', 'CS', 4660);
INSERT INTO class_list VALUES (505, 'people_DEP3', 'CS', 4745);
INSERT INTO thread_requirement VALUES (118, 'people', 'people_DEP3', 6);
INSERT INTO thread VALUES ('sysarc', 0);
INSERT INTO class_list VALUES (506, 'sysarc_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (507, 'sysarc_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (508, 'sysarc_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (509, 'sysarc_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (510, 'sysarc_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (511, 'sysarc_DEP1', 'CS', 2200);
INSERT INTO class_list VALUES (512, 'sysarc_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (513, 'sysarc_DEP1', 'CS', 3210);
INSERT INTO class_list VALUES (514, 'sysarc_DEP1', 'CS', 3220);
INSERT INTO class_list VALUES (515, 'sysarc_DEP1', 'CS', 3510);
INSERT INTO class_list VALUES (516, 'sysarc_DEP1', 'ECE', 2031);
INSERT INTO thread_requirement VALUES (119, 'sysarc', 'sysarc_DEP1', -1);
INSERT INTO class_list VALUES (517, 'sysarc_DEP2', 'CS', 4210);
INSERT INTO class_list VALUES (518, 'sysarc_DEP2', 'CS', 4220);
INSERT INTO class_list VALUES (519, 'sysarc_DEP2', 'CS', 4290);
INSERT INTO thread_requirement VALUES (120, 'sysarc', 'sysarc_DEP2', 3);
INSERT INTO class_list VALUES (520, 'sysarc_DEP3', 'CS', 3300);
INSERT INTO class_list VALUES (521, 'sysarc_DEP3', 'CS', 4240);
INSERT INTO thread_requirement VALUES (121, 'sysarc', 'sysarc_DEP3', 3);
INSERT INTO thread VALUES ('theory', 0);
INSERT INTO class_list VALUES (522, 'theory_DEP1', 'CS', 1301);
INSERT INTO class_list VALUES (523, 'theory_DEP1', 'CS', 1331);
INSERT INTO class_list VALUES (524, 'theory_DEP1', 'CS', 1332);
INSERT INTO class_list VALUES (525, 'theory_DEP1', 'CS', 2050);
INSERT INTO class_list VALUES (526, 'theory_DEP1', 'CS', 2110);
INSERT INTO class_list VALUES (527, 'theory_DEP1', 'CS', 2340);
INSERT INTO class_list VALUES (528, 'theory_DEP1', 'CS', 3510);
INSERT INTO class_list VALUES (529, 'theory_DEP1', 'CS', 4510);
INSERT INTO class_list VALUES (530, 'theory_DEP1', 'CS', 4540);
INSERT INTO class VALUES ('MATH', 3406, 'MATH3406', 'MATH3406 description');
INSERT INTO class_list VALUES (531, 'theory_DEP1', 'MATH', 3406);
INSERT INTO thread_requirement VALUES (122, 'theory', 'theory_DEP1', -1);
INSERT INTO class VALUES ('MATH', 4022, 'MATH4022', 'MATH4022 description');
INSERT INTO class_list VALUES (532, 'theory_DEP2', 'MATH', 4022);
INSERT INTO class VALUES ('MATH', 4032, 'MATH4032', 'MATH4032 description');
INSERT INTO class_list VALUES (533, 'theory_DEP2', 'MATH', 4032);
INSERT INTO class VALUES ('MATH', 4150, 'MATH4150', 'MATH4150 description');
INSERT INTO class_list VALUES (534, 'theory_DEP2', 'MATH', 4150);
INSERT INTO thread_requirement VALUES (123, 'theory', 'theory_DEP2', 3);

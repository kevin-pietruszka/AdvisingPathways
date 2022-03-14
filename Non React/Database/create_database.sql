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

CREATE TABLE thread (
	thread_name 		VARCHAR(255) NOT NULL PRIMARY KEY,
	fe_hrs_required 	INT NOT NULL -- free elective hours 
);

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
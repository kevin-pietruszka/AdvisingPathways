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
	class_list_name 	VARCHAR(255) NOT NULL PRIMARY KEY,
    department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number)
);

CREATE TABLE class_prerequisite (
	prereq_id 			INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    department 			VARCHAR(255) NOT NULL,
    class_number		INT NOT NULL,
    class_list_name 	VARCHAR(255) NOT NULL,
    FOREIGN KEY (department, class_number) REFERENCES class(department, class_number),
    FOREIGN KEY (class_list_name) REFERENCES class_list(class_list_name)
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
    FOREIGN KEY (thread_name) REFERENCES thread(thread_name),
    FOREIGN KEY (class_list_name) REFERENCES class_list(class_list_name)
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


INSERT into user VALUES ('admin', "", "Team", "Galactic", 0, 0, "DialgaPalkia$13")
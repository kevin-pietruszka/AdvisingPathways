# Advising Pathways

The Advising Pathways project is a robust and intuitive web application that facilitates exploration of curriculum requirements and options through surveys, gamified walkthroughs, and detailed advising information.

The IP for software developed by students remains with the students. All other IP, including
client provided code, business ideas, and processes, remains with the client.

The open-source license chosen for this project is: MIT License.

Questions regarding IP should be directed to Amanda Girard at amanda.girard@lmc.gatech.edu

# Release Notes

## Version v0.5.0

### Features

- Updated walkthrough to use JSON file structure for data
- Built out walkthrough UI
- Framework for curriculum saving adjusted to utilize JSON 

### Bug Fixes

- Fixed Walkthrough crashing after clear

### Known Issues

- Password entry is not hidden
- Recommendation is currently an alert box
- Database needs connection to JSON data files used by walkthrough
- Curriculum saving needs to be implemented through login.js, or with AJAX
- Walkthrough needs comprehensive updating of current courses
- UI needs to be refined on walkthrough for ease of use
- UI indicators for hours and course requirements need to be added to Walkthrough
- Survey needs UI overhaul

## Version v0.4.0

### Features

- Survey made with SurveyJS framework to recommend threads to user
- Walkthrough feature built out with temporary data
- Framework for curriculum saving implemented

### Bug Fixes

- N/A

### Known Issues

- Password entry is not hidden
- Recommendation is currently an alert box
- Walkthrough needs connection to database
- Walkthrough needs comprehensive updating of current courses

## Version v0.3.0

### Features

- React integrated with node and MySQL
- Framework for gamified walkthrough built into database

### Bug Fixes

- N/A

### Known Issues

- Password entry is not hidden

## Version v0.2.0

### Features

- Login functionality fully implemented with SQL database
- Advising appointment scheduling linked to homepage
- Full user registration functionality

### Bug Fixes

- N/A

### Known Issues

- None

## Version v0.1.0

### Features

- Rudimentary GUI implementation
- User login functionality

### Bug Fixes

- N/A

### Known Issues

- None


# Installation Guide

## Pre-requisites

### Hardware
The device that will be running the web application will need to have a domain name that routes to the ip address of the machine and port number that the application is running on. For optimal performance, a server should host the web application. Multiple cores are recommended to be able to handle more simultaneous connections and a lot of RAM is needed in order to maintain these connections. 

### Software
The following software needs to be installed before the code can be ran in an environment:
Node.js (https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
MySQL (https://dev.mysql.com/doc/mysql-installation-excerpt/5.7/en/)
For Node.js all that is needed is to downloaded installer match the version of your operating system. The version of Node.js should not matter since we did not use any depreciated libraries.
For MySQL, the server version needs to be installed and only needs to run as a local host on the machine hostine the web application. Our current code uses a custom user of MySQL server (https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql) with the user: “galactic” and password: “DialgaPalkia!13”. It is highly recommended to change these values by either making a similar user or by using the default “root” user that has the password specified by installation. To change the values of user in the password to properly work in code, modify lines 11 and 12 of login.js to adjust for the user set up in the MySQL server upon installation. 

## Download Instructions
There are two options, if GIT is installed on the machine, the command “git clone https://github.com/kevin-pietruszka/AdvisingPathways.git” can be used to download the project into a directory. Otherwise, go to https://github.com/kevin-pietruszka/AdvisingPathways and press the green “Code” button and press download zip and extract the contents to a destination of your choice.

## Dependencies
All dependencies can be installed through the Node Package Manager (NPM). To install the dependencies, use the command line/terminal and navigate to the project directory (advising-pathways). Then run the command: npm install. This should automatically install all of the dependencies that are defined in the package.json file. Otherwise for the following dependencies you would have to run “npm install {dependency name} –save”:
- async 
- constants 
- create-require
- express
- express-session
- mysql
- mysql2
- react
- react-dom
- react-router-dom
- react-scripts
- survey-react
- web-vitals. 

Additionally, the command “npm install -g serve” needs to be run to install the package that will host the build of the application.

## Building, Installing, and Running the Application
To build the application, run the command: npm run build. This installs a production build to a directory named “build” that will serve the users the index.html file and the requests to webpages. The last item to do, is to run the command: serve -s build -l 3000. This will host the server on the device at port number 3000. To change the port, simply change the number 3000 to the desired port number.


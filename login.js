const mysql = require('mysql2');
const express = require('express');
const session = require('express-session');
const path = require('path');
const exp = require('constants');

const app = express();

const sql_connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'galactic',
	password : 'DialgaPalkia!13',
	database : 'advising_pathways',
});

sql_connection.connect(function(err) {
	if (err) throw err;
	console.log("Connected!");
});

app.use(express(__dirname + "/static"));

app.use(session({
	secret: 'secret',
	resave: true,
	saveUninitialized: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// ***************** Declare static directories  ******************** //

app.use(express.static(path.join(__dirname, 'static')));
app.use(express.static(path.join(__dirname, 'Register')));
app.use(express.static(path.join(__dirname, 'Homepage')));

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'src')));

// ********************* Post messages ******************//

// http://localhost:3000/auth
app.post('/auth', function(request, response) {
	// Capture the input fields
	let username = request.body.username;
	let password = request.body.password;

	// Ensure the input fields exists and are not empty
	if (username && password) {

		// Execute SQL query that'll select the account from the database based on the specified username and password
		sql_connection.query('SELECT * FROM user WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
			// If there is an issue with the query, output the error
			if (error) throw error;
			// If the account exists
			if (results.length > 0) {
				// Authenticate the user
				request.session.loggedin = true;
				request.session.username = username;
				// Redirect to home page
				response.redirect('/home');
			} else {
				response.send('Incorrect Username and/or Password!');
				response.end();
			}

		});
	} else {

		response.send('Please enter Username and Password!');
		response.end();
	}

	
});

app.post('/register', function(request, response) {

	let username = request.body.username;
	let email = request.body.email;
	// TODO redesign page to allow
	// let fname = request.body.firstname;
	// let lname = request.body.lastname;
	let password = request.body.password;
	let c_password = request.body.cPassword;

	// TODO update html to include name and student info 

	if (password == c_password) {

		sql_connection.query('SELECT username, email FROM user WHERE username = ? OR email = ?', [username, email], function(error, results, fields) {

			if (error) throw error;
			
			if (results.length > 0 ) {

				response.send("Username or email alreadt exist, try again.");

			} else {

				let values = '\"' + username + '\", \"' + email + '\", \"test\", \"test\", 1, 0, \"' + password + "\"";
				let q = "INSERT INTO user VALUES ("+ values + ")";
				console.log(q)

				sql_connection.query(q, function(err, results ) {
					
					if (err) throw err;

					console.log("Successful register");

				})

				request.session.loggedin = true;
				request.session.username = username;
				response.redirect('/home');

			}
		})

	} else {

		response.send("Passwords do not match!");

	}

})

app.post("/signup",  function(request, response) {
	response.redirect("/reg");
})

// ***************** Get Requests ******************** //

// http://localhost:3000/
app.get('/', function(request, response) {
	
	response.sendFile(__dirname + '/public/index.html');

});

app.get('/reg', function(request, response) {
	
	response.sendFile(__dirname + '/public/index.html');

});

// http://localhost:3000/home
app.get('/home', function(request, response) {
	
	if (request.session.loggedin) {
		response.sendFile(__dirname + '/public/index.html');
	} else {
		response.redirect("/");
	}

});

app.listen(3001)
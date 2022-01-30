

const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

app.use('/public', express.static('public'));
app.use('/img',express.static(path.join(__dirname, 'public/image')));
app.use('/js',express.static(path.join(__dirname, 'public/js')));
app.use('/css',express.static(path.join(__dirname, 'public/css')));

// sendFile will go here
app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname, '/index.html'));
});

app.get('/index.html', function(req, res) {
  res.sendFile(path.join(__dirname, '/index.html'));
});

app.get('/register.html', function(req, res) {
    res.sendFile(path.join(__dirname, '/register.html'));
});

app.get('/homepage.html', function(req, res) {
    res.sendFile(path.join(__dirname, '/homepage.html'));
});


app.listen(port);
console.log('Server started at http://localhost:' + port);
const express = require('express');
const path = require('path');
const cp = require('child_process');

const app = express();

// Serve static files from 'public' folder
app.use(express.static('public'));

// Set 'views' folder and view engine
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'hbs');

// Home page route
app.get('/', (req, res) => {
  res.render('index');
});

// About page route
app.get('/about', (req, res) => {
  res.render('about');
});

// Contact page route
app.get('/contact', (req, res) => {
  res.render('contact');
});

// Vulnerable dns route
app.get('/dns', (req, res) => {
  const ip = req.query.ip;

  if (isSafeInput(ip)) {
    try {
      const commandOutput = cp.execSync("nslookup " + ip + " 2>&1").toString();
      res.send('Command Output: ' + commandOutput);
    } catch (error) {
      res.send('Error: ' + error.message);
    }
  } else {
    res.send('Nope. You have to try harder !');
  }
});

// Check for unsafe input (e.g., unsafe keywords except "head")
function isSafeInput(input) {
  const unsafeKeywords = ["cat", "tail", "less", "more", "awk", "&&", "head", "|", "$", "`", "<", ">", "&", "*"];
  return !unsafeKeywords.some(keyword => input.includes(keyword)) || input === "head";
}

// Start server
app.listen(3000, () => {
  console.log('Server listening on port 3000');
});
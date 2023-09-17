# CSAW'23

## AndroidDropper

> 
> This app does nothing!
> 
> dropper.apk sha256sum: `aaf49dcee761d13da52a95f86b7b92596e7b63c14d0a04bce5dd24c7927ecea9`
>
>  Author: gchip
>
> [`dropper.apk`](dropper.apk)

Tags: __misc__

## Solution
This challenge comes with a `apk` we can open in [`JADX`](https://github.com/skylot/jadx). Within we find the `MainActivity` of the application decodes some `base64` payload, writes it to `dropped.dex` and creates a new instance from this. We also can see the dropped object class has a method called `getFlag`, that looks promising. 

```java
try {
    byte[] decode = Base64.decode("ZGV4CjAzNQAWORryq3+hLJ+yXt9y3L5lCBAqyp3c8Q6UBwAAcAAAAHhWNBIAAAAAAAAAANAGAAAoAAAAcAAAABMAAAAQAQAACwAAAFwBAAABAAAA4AEAABAAAADoAQAAAQAAAGgCAAAMBQAAiAIAAPYDAAD4AwAAAAQAAA4EAAARBAAAFAQAABoEAAAeBAAAPQQAAFkEAABzBAAAigQAAKEEAAC+BAAA0AQAAOcEAAD7BAAADwUAAC0FAAA9BQAAVwUAAHMFAACHBQAAigUAAI4FAACSBQAAlgUAAJ8FAACnBQAAswUAAL8FAADIBQAA2AUAAPIFAAD+BQAAAwYAABMGAAAkBgAALgYAADUGAAADAAAABwAAAAgAAAAJAAAACgAAAAsAAAAMAAAADQAAAA4AAAAPAAAAEAAAABEAAAASAAAAEwAAABQAAAAVAAAAFgAAABgAAAAZAAAABAAAAAUAAAAAAAAABAAAAAoAAAAAAAAABQAAAAoAAADMAwAABAAAAA0AAAAAAAAABAAAAA4AAAAAAAAAFgAAABAAAAAAAAAAFwAAABAAAADYAwAAFwAAABAAAADgAwAAFwAAABAAAADoAwAAFwAAABAAAADwAwAABgAAABEAAADoAwAAAQARACEAAAABAAUAAQAAAAEAAQAeAAAAAQACACIAAAADAAcAAQAAAAMAAQAlAAAABgAGAAEAAAAIAAUAJAAAAAkABQABAAAACgAJAAEAAAALAAUAGgAAAAsABQAcAAAACwAAAB8AAAAMAAgAAQAAAAwAAwAjAAAADgAKABsAAAAPAAQAHQAAAAEAAAABAAAACQAAAAAAAAACAAAAuAYAAJYGAAAAAAAABAAAAAMAAgCoAwAASwAAAAAAIgAMABoBIABwIAwAEABuEA0AAAAMAB8ACwBuEAkAAAAiAQMAIgIGAG4QCwAAAAwDcCAFADIAcCADACEAbhAEAAEADAFuEAoAAAAoDA0BKB8NAW4QBgABAG4QCgAAABoBAABxAA8AAAAMAG4gDgAQAAwAaQAAABMAEwETATIBEwIqAHEwAgAQAgwAEQBuEAoAAAAnAQAADgAAABUAAQAqAAAAAwAFAAJ/CCknACcABwADAAIAAAC/AwAAGQAAALFFI1ASABIBNVEPAGICAACQAwQBSAICA7dijiJQAgAB2AEBASjyIgQKAHAgCAAEABEEAAABAAEAAQAAAKQDAAAEAAAAcBAHAAAADgAKAA4AEQAOHnhqPOFOPBwpHj08LqamAnkdPAAnAwAAAA48PKM+AAAAAwAAAAAAAAAAAAAAAQAAAAUAAAABAAAABwAAAAEAAAAKAAAAAQAAABIAAAAGPGluaXQ+AAxEcm9wcGVkLmphdmEAAUkAAUwABExJSUkAAkxMAB1MY29tL2V4YW1wbGUvZHJvcHBlZC9Ecm9wcGVkOwAaTGRhbHZpay9hbm5vdGF0aW9uL1Rocm93czsAGExqYXZhL2lvL0J1ZmZlcmVkUmVhZGVyOwAVTGphdmEvaW8vSU9FeGNlcHRpb247ABVMamF2YS9pby9JbnB1dFN0cmVhbTsAG0xqYXZhL2lvL0lucHV0U3RyZWFtUmVhZGVyOwAQTGphdmEvaW8vUmVhZGVyOwAVTGphdmEvbGFuZy9FeGNlcHRpb247ABJMamF2YS9sYW5nL09iamVjdDsAEkxqYXZhL2xhbmcvU3RyaW5nOwAcTGphdmEvbmV0L0h0dHBVUkxDb25uZWN0aW9uOwAOTGphdmEvbmV0L1VSTDsAGExqYXZhL25ldC9VUkxDb25uZWN0aW9uOwAaTGphdmEvdXRpbC9CYXNlNjQkRGVjb2RlcjsAEkxqYXZhL3V0aWwvQmFzZTY0OwABVgACVkwAAltCAAJbQwAHY29ubmVjdAAGZGVjb2RlAApkaXNjb25uZWN0AApnZXREZWNvZGVyAAdnZXRGbGFnAA5nZXRJbnB1dFN0cmVhbQAYaHR0cDovL21pc2MuY3Nhdy5pbzozMDAzAApub3RUaGVGbGFnAANvYmYADm9wZW5Db25uZWN0aW9uAA9wcmludFN0YWNrVHJhY2UACHJlYWRMaW5lAAV2YWx1ZQBXfn5EOHsiY29tcGlsYXRpb24tbW9kZSI6ImRlYnVnIiwiaGFzLWNoZWNrc3VtcyI6ZmFsc2UsIm1pbi1hcGkiOjEsInZlcnNpb24iOiIyLjEuNy1yMSJ9AAICASYcARgEAQADAAAIAIGABIwHAQmIBQEJyAYAAAAAAAABAAAAjgYAAKwGAAAAAAAAAQAAAAAAAAABAAAAsAYAABAAAAAAAAAAAQAAAAAAAAABAAAAKAAAAHAAAAACAAAAEwAAABABAAADAAAACwAAAFwBAAAEAAAAAQAAAOABAAAFAAAAEAAAAOgBAAAGAAAAAQAAAGgCAAABIAAAAwAAAIgCAAADIAAAAwAAAKQDAAABEAAABQAAAMwDAAACIAAAKAAAAPYDAAAEIAAAAQAAAI4GAAAAIAAAAQAAAJYGAAADEAAAAgAAAKwGAAAGIAAAAQAAALgGAAAAEAAAAQAAANAGAAA=", 0);
    FileOutputStream openFileOutput = openFileOutput("dropped.dex", 0);
    openFileOutput.write(decode);
    openFileOutput.flush();
    openFileOutput.close();
} catch (IOException e) {
    e.printStackTrace();
}
StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder().permitAll().build());
File file = new File(getFilesDir(), "dropped.dex");
Method method = null;
try {
    cls = new DexClassLoader(file.getAbsolutePath(), getCacheDir().getAbsolutePath(), null, getClassLoader()).loadClass("com.example.dropped.Dropped");
} catch (ClassNotFoundException e2) {
    e2.printStackTrace();
    cls = null;
}
try {
    obj = cls.newInstance();
} catch (IllegalAccessException | InstantiationException e3) {
    e3.printStackTrace();
    obj = null;
}
try {
    method = cls.getMethod("getFlag", null);
} catch (NoSuchMethodException e4) {
    e4.printStackTrace();
}
try {
    method.invoke(obj, new Object[0]);
} catch (IllegalAccessException | InvocationTargetException e5) {
    e5.printStackTrace();
}
file.delete();
AlertDialog.Builder builder = new AlertDialog.Builder(this);
builder.setMessage("test");
builder.show();
finish();
System.exit(0);
```

Lets decompile the dropped dex as well. We decode the base64 payload and open the file with `JADX`.

```bash
echo -n "ZGV4CjAzNQAWORryq3+hLJ+yXt9y3L5lCBAqyp3c8Q6UBwAAcAAAAHhWNBIAAAAAAAAAANAGAAAoAAAAcAAAABMAAAAQAQAACwAAAFwBAAABAAAA4AEAABAAAADoAQAAAQAAAGgCA..." | | base64 -d > dropped.dex
```

The method `getFlag` calls `http://misc.csaw.io:3003` and reads in the result. The result string is again base64 decoded and then passed to `obf`.

```java
public class Dropped {
    static byte[] notTheFlag;

    public static String getFlag() throws IOException {
        String str;
        HttpURLConnection httpURLConnection = (HttpURLConnection) new URL("http://misc.csaw.io:3003").openConnection();
        try {
            try {
                httpURLConnection.connect();
                str = new BufferedReader(new InputStreamReader(httpURLConnection.getInputStream())).readLine();
            } catch (Exception e) {
                e.printStackTrace();
                httpURLConnection.disconnect();
                str = "";
            }
            notTheFlag = Base64.getDecoder().decode(str);
            return obf(275, 306, 42);
        } finally {
            httpURLConnection.disconnect();
        }
    }

    public static String obf(int i, int i2, int i3) {
        int i4 = i2 - i;
        char[] cArr = new char[i4];
        for (int i5 = 0; i5 < i4; i5++) {
            cArr[i5] = (char) (notTheFlag[i + i5] ^ i3);
        }
        return new String(cArr);
    }
}
```

Lets grab the result that `http://misc.csaw.io:3003` gives us:

```bash
bEVYCkNEWV5LRElPBgpFRApeQk8KWkZLRE9eCm9LWF5CBgpHS0QKQktOCktGXUtTWQpLWVlfR09OCl5CS14KQk8KXUtZCkdFWE8KQ0ReT0ZGQ01PRF4KXkJLRApORUZaQkNEWQpIT0lLX1lPCkJPCkJLTgpLSUJDT1xPTgpZRQpHX0lCCgcKXkJPCl1CT09GBgpkT10Kc0VYQQYKXUtYWQpLRE4KWUUKRUQKBwpdQkNGWV4KS0ZGCl5CTwpORUZaQkNEWQpCS04KT1xPWApORURPCl1LWQpHX0lBCktIRV9eCkNECl5CTwpdS15PWApCS1xDRE0KSwpNRUVOCl5DR08ECmhfXgpJRURcT1hZT0ZTBgpJWUtdSV5MUU5TRB5HG0l1RkUeTk94WXVYdUxfZAtXIF5CTwpORUZaQkNEWQpCS04KS0ZdS1NZCkhPRkNPXE9OCl5CS14KXkJPUwpdT1hPCkxLWApHRVhPCkNEXk9GRkNNT0ReCl5CS0QKR0tECgcKTEVYClpYT0lDWU9GUwpeQk8KWUtHTwpYT0tZRURZBA
```

If we decode it we get a number of weird lines

```bash
lEX
CDY^KDIO
ED
^BO
ZFKDO^
oKX^B
GKD
BKN
KF]KSY
KYY_GON
^BK^
BO
]KY
```

We can rewrite the code with `Python` but the faster way would be to compile the decompiled code again and let it print the flag for us.

```java
import java.util.Base64;
import java.io.*;
import java.net.*;

public class Dropped {
    static byte[] notTheFlag;

    public static void main(String[] args) {
        try {
            System.out.println(Dropped.getFlag());
        } catch (Exception e) {
        }
    }
/// .. rest stays the same
```

```bash
$ javac Dropped.java
$ $ java Dropped
csawctf{dyn4m1c_lo4deRs_r_fuN!}
```

Flag `csawctf{dyn4m1c_lo4deRs_r_fuN!}`
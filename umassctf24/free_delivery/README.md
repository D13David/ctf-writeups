# UMass CTF 2024

## Free Delivery

> Mr. Krabs has decided to make a new food delivery app for the Krusty Krab but Plankton decided to make his own patched version. Loyal Krusty Krab customers are saying weird network traffic and shell commands are coming from the app! Can you figure out what's going on?
> 
> [`free-delivery.apk`](free-delivery.apk)

Tags: _rev_

## Solution
The challenge comes with an apk to inspect. We can open it in [`JADX`](https://github.com/skylot/jadx). We can find the `MainActivity` doning some interesting things, but symbols are not given, so a bit of cleanup should be done first. The one more interesting bit is a `AsyncTask` that is launched when clicking a button.

```java
public class a extends AsyncTask<Void, Void, String> {
    public a() {
    }

    @Override // android.os.AsyncTask
    /* renamed from: a  reason: avoid collision after fix types in other method */
    public String doInBackground(Void... voidArr) {
        try {
            MainActivity mainActivity = MainActivity.this;
            StringBuilder sb = new StringBuilder();
            sb.append(MainActivity.Base64Decode("aHR0cDovLzEyNy4wLjAuMToxMjU0"));
            MainActivity mainActivity2 = MainActivity.this;
            sb.append(mainActivity2.EncryptAndBase64Encode(mainActivity2.f12220f));
            mainActivity.RequestUnderVerySpecialCondition(sb.toString());
            MainActivity mainActivity3 = MainActivity.this;
            StringBuilder sb2 = new StringBuilder();
            sb2.append(MainActivity.Base64Decode("aHR0cDovLzEyNy4wLjAuMToxMjU0"));
            MainActivity mainActivity4 = MainActivity.this;
            sb2.append(mainActivity4.EncryptAndBase64Encode(mainActivity4.GetMacAddress()));
            mainActivity3.RequestUnderVerySpecialCondition(sb2.toString());
            MainActivity mainActivity5 = MainActivity.this;
            mainActivity5.RequestUnderVerySpecialCondition(MainActivity.Base64Decode("aHR0cDovLzEyNy4wLjAuMToxMjU0") + "AzE9Omd0eG8XHhEcHTx1Nz0dN2MjfzF2MDYdICE6fyMa");
            return "";
        } catch (Exception e8) {
            e8.printStackTrace();
            return "";
        }
    }
}
```

The function calls out to `http://127.0.0.1:1254` (which is base64 encoded `aHR0cDovLzEyNy4wLjAuMToxMjU0`) and sends some data. The first two times only some string and the phones `mac address` is send, its not to useful. The last time an string is send, but base64 decoding doesnt give a good result. The interesting thing is that the first two times the data is going through a function that does an additional xor encryption together with base64 encode (therefore I renamed it to `EncryptAndBase64Encode`).

```java
public String EncryptAndBase64Encode(String str) {
    return Base64.encodeToString(Xor(str.getBytes(StandardCharsets.UTF_8)), 0);
}
public byte[] Xor(byte[] bArr) {
    byte[] bytes = "SPONGEBOBSPONGEBOBSPONGEBOBSPONGEBOBSPONGEBOB".getBytes();
    for (int i8 = 0; i8 < bArr.length; i8++) {
        bArr[i8] = (byte) (bArr[i8] ^ bytes[i8 % bytes.length]);
    }
    return bArr;
}
```

So, we can assume the server does the reverse and the last input is already prepared (since the function is not called explicitely). Lets try this with [`CyberChef`](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)XOR(%7B'option':'UTF8','string':'SPONGEBOBSPONGEBOBSPONGEBOBSPONGEBOBSPONGEBOB'%7D,'Standard',false)&input=QXpFOU9tZDBlRzhYSGhFY0hUeDFOejBkTjJNamZ6RjJNRFlkSUNFNmZ5TWE), and we get `Part 1: UMASS{0ur_d3l1v3ry_squ1d_`.

So there is a second part somewhere. Digging around a bit we find there is an native binding used.

```java
public static class rgae {
    /* renamed from: a */
    public static String Part2Flag() {
        return t();
    }

    public static String b() {
        return MainActivity.Base64Decode("T3JkZXJlZCBLZWxwIFNoYWtlIQ==");
    }

    private static native String t();
}

static {
    System.loadLibrary("freedelivery");
}
```

Extracting the library from the apk (by just unzipping the apk for instance) and inspecting it with `Ghidra` gives us the following:

```c
undefined8 Java_com_example_freedelivery_MainActivity_00024rgae_t(long *param_1)
{
  undefined8 uVar1;
  long i;
  long in_FS_OFFSET;
  undefined4 local_6f;
  undefined4 uStack_6b;
  undefined4 uStack_67;
  undefined3 uStack_63;
  undefined uStack_60;
  undefined4 uStack_5f;
  char cStack_59;
  undefined local_58 [16];
  undefined auStack_48 [13];
  undefined3 local_3b;
  undefined auStack_38 [12];
  undefined uStack_2c;
  long local_20;
  
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  local_6f._0_1_ = 'O';
  local_6f._1_1_ = 'r';
  local_6f._2_1_ = 'd';
  local_6f._3_1_ = 'e';
  uStack_6b._0_1_ = 'r';
  uStack_6b._1_1_ = 'e';
  uStack_6b._2_1_ = 'd';
  uStack_6b._3_1_ = ' ';
  uStack_67._0_1_ = 'C';
  uStack_67._1_1_ = 'o';
  uStack_67._2_1_ = 'r';
  uStack_67._3_1_ = 'a';
  uStack_63 = 0x42206c;
  uStack_60 = 0x69;
  uStack_5f = 0x217374;
  auStack_38 = SUB1612(ZEXT816(0),3);
  uStack_2c = 0;
  auStack_48 = SUB1613(ZEXT816(0),0);
  local_3b = 0;
  local_58 = ZEXT816(0);
  i = 0;
  do {
    i = (long)(int)i;
    local_58[i] = (&DAT_0010e6ec)[i] ^ 0x55;
    i = (i + 1) * (long)c;
  } while (local_58[i + -1] != '\0');
  uStack_2c = 0;
                    /* try { // try from 00116752 to 0011676a has its CatchHandler @ 001167a1 */
  system(local_58);
  uVar1 = (**(code **)(*param_1 + 0x538))(param_1,&local_6f);
  if (*(long *)(in_FS_OFFSET + 0x28) != local_20) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return uVar1;
}
```

There is a call to `system` and the value is before read from data `DAT_0010e6ec` and xored with `0x55`. This looks suspicious, lets see what we have here.

```python
data = b'\x36\x3d\x3a\x75\x77\x05\x34\x27\x21\x75\x01\x22\x3a\x6f\x75\x22\x64\x39\x39\x0a\x37\x27\x64\x3b\x32\x0a\x64\x21\x0a\x27\x64\x32\x3d\x21\x0a\x65\x23\x66\x27\x0a\x74\x28\x77\x55'

for x in data:
    print(chr(x^0x55),end="")
```

```bash
cho "Part Two: w1ll_br1ng_1t_r1ght_0v3r_!}"
```

Flag `UMASS{0ur_d3l1v3ry_squ1d_w1ll_br1ng_1t_r1ght_0v3r_!}`
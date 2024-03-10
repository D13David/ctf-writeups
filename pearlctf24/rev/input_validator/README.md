# PearlCTF 2024

## input-validator

> Can you find the correct input?
>
>  Author: v1per
>
> [`input_validator.class`](input_validator.class)

Tags: _rev_

## Solution
This challenge is a rather easy java decompile challenge. We can use [`online tools`](http://www.javadecompilers.com/) for this. The decompiled code looks like this:

```java
import java.util.Scanner;

public class input_validator {
   private static final int FLAG_LEN = 34;

   private static boolean validate(String var0, String var1) {
      int[] var2 = new int[34];
      int[] var3 = new int[]{1102, 1067, 1032, 1562, 1612, 1257, 1562, 1067, 1012, 902, 882, 1397, 1472, 1312, 1442, 1582, 1067, 1263, 1363, 1413, 1379, 1311, 1187, 1285, 1217, 1313, 1297, 1431, 1137, 1273, 1161, 1339, 1267, 1427};

      int var4;
      for(var4 = 0; var4 < 34; ++var4) {
         var2[var4] = var0.charAt(var4) ^ var1.charAt(var4);
      }

      for(var4 = 0; var4 < 34; ++var4) {
         var2[var4] -= var1.charAt(33 - var4);
      }

      int[] var6 = new int[34];

      int var5;
      for(var5 = 0; var5 < 17; ++var5) {
         var6[var5] = var2[1 + var5 * 2] * 5;
         var6[var5 + 17] = var2[var5 * 2] * 2;
      }

      for(var5 = 0; var5 < 34; ++var5) {
         var6[var5] += 1337;
      }

      for(var5 = 0; var5 < 34; ++var5) {
         if (var6[var5] != var3[var5]) {
            return false;
         }
      }

      return true;
   }

   public static void main(String[] var0) {
      Scanner var1 = new Scanner(System.in);
      String var2 = "oF/M5BK_U<rqxCf8zWCPC(RK,/B'v3uARD";
      System.out.print("Enter input: ");
      String var3 = var1.nextLine();
      if (var3.length() != 34) {
         System.out.println("Input length does not match!");
      } else {
         if (validate(new String(var3), var2)) {
            System.out.println("Correct");
         } else {
            System.out.println("Wrong");
         }

      }
   }
}
```

We have some input processing in validate. Since we have the target values for each flag character, we can just implement the inverse for the logic:

```python
var3 = [1102, 1067, 1032, 1562, 1612, 1257, 1562, 1067, 1012, 902, 882, 1397, 1472, 1312, 1442, 1582, 1067, 1263, 1363, 1413, 1379, 1311, 1187, 1285, 1217, 1313, 1297, 1431, 1137, 1273, 1161, 1339, 1267, 1427]

key = b"oF/M5BK_U<rqxCf8zWCPC(RK,/B'v3uARD"

var2 = [None]*len(var3)

for i in range(len(var3)):
    var3[i] = var3[i] - 1337

for i in range(17):
    var2[i*2] = var3[i+17]//2
    var2[i*2+1] = var3[i]//5

for i in range(len(var2)):
    var2[i] += key[33-i]
    var2[i] ^= key[i]
    var2[i] = chr(var2[i])

print("".join(var2))
```

Running this gives us the flag.

Flag `pearl{w0w_r3v3r51ng_15_50_Ea5y_!!}`
# BuckeyeCTF 2023

## Currency Converter

> Need to convert USD to another currency? Well I hope its either Euros, Canadian, or Yen!
>
>  Author: geekgeckoalex
>
> [`converter.jar`](converter.jar)

Tags: _rev_

## Solution
We can get the flag simply by decompiling the `jar` with [`JADX`](https://github.com/skylot/jadx).

```java
public class CurrencyConverter {
    public static String convert_euro(double d) {
        return "Euro: " + (d * 0.92d);
    }

    public static String convert_canada(double d) {
        return "Canadian: " + (d * 1.36d);
    }

    public static String convert_yen(double d) {
        return "Japanese Yen: " + (d * 145.14d);
    }

    private static String flag() {
        return "bctf{o0ps_y0u_fOuNd_mE}";
    }
}
```

Flag `bctf{o0ps_y0u_fOuiNd_mE}`
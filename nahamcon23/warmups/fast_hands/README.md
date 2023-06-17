# NahamCon 2023

## Fast Hands

> You can capture the flag, but you gotta be fast!
>
>  Author: @JohnHammond#6971
>

Tags: _warmups_

## Solution
A simple page with a single button is provided. When clicking the button a second window appears and is closed right afterwards. Inspecting the source code gives the following javascript snipped.

```javascript
function ctf() {
    window.open("./capture_the_flag.html", 'Capture The Flag', 'width=400,height=100%,menu=no,toolbar=no,location=no,scrollbars=yes');
}
```

To inspect the file it can be downloaded by using `curl` or `wget`. Inside the html file the flag can be found.

```html
<div class="text-center mt-5 p-5">
    <button type="button" onclick="ctf()" class="btn btn-success"><h1>Your flag is:<br>
        &nbsp;...
        <span style="display:none">
        flag{80176cdf1547a9be54862df3568966b8}
    </span></button>
</div>
```

Flag `flag{80176cdf1547a9be54862df3568966b8}`